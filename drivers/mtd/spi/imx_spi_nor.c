/*
 * (C) Copyright 2013 CompuLab, Ltd.
 *
 * Author: Igor Grinberg <grinberg@compulab.co.il>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc.
 */

#include <config.h>
#include <common.h>
#include <spi.h>
#include <spi_flash.h>
#include <asm/errno.h>
#include <linux/types.h>
#include <malloc.h>

#include <imx_spi.h>
#include <imx_spi_nor.h>

#define MFR_ATMEL	0x1F
#define MFR_SST		0xBF
#define MFR_ST		0x20 /* STMicroelectronics */

u8 g_tx_buf[IMX_SPI_NOR_TRX_BUF_LEN];
u8 g_rx_buf[IMX_SPI_NOR_TRX_BUF_LEN];

static const struct imx_spi_flash_vendor imx_spi_flash_table[] = {
#ifdef CONFIG_SPI_FLASH_IMX_SST
	{
		.mfr_id	= MFR_SST,
		.probe	= spi_flash_probe_sst,
	},
#endif /* CONFIG_SPI_FLASH_IMX_SST */
#ifdef CONFIG_SPI_FLASH_IMX_M25PXX
	{
		.mfr_id	= MFR_ST,
		.probe	= spi_flash_probe_m25pxx,
	},
#endif /* CONFIG_SPI_FLASH_IMX_M25PXX */
#ifdef CONFIG_SPI_FLASH_IMX_ATMEL
	{
		.mfr_id	= MFR_ATMEL,
		.probe	= spi_flash_probe_atmel,
	},
#endif /* CONFIG_SPI_FLASH_IMX_ATMEL */
};

int spi_nor_flash_query(struct spi_flash *flash, void* data)
{
	u8 au8Tmp[4] = { 0 };
	u8 *pData = (u8 *)data;

	g_tx_buf[3] = JEDEC_ID;

	if (spi_xfer(flash->spi, (4 << 3), g_tx_buf, au8Tmp,
				SPI_XFER_BEGIN | SPI_XFER_END)) {
		return -1;
	}

	printf("JEDEC ID: 0x%02x:0x%02x:0x%02x\n",
			au8Tmp[2], au8Tmp[1], au8Tmp[0]);

	pData[0] = au8Tmp[2];
	pData[1] = au8Tmp[1];
	pData[2] = au8Tmp[0];

	return 0;
}

s32 spi_nor_status(struct spi_flash *flash, u8 status_code)
{
	g_tx_buf[1] = status_code;

	if (spi_xfer(flash->spi, 2 << 3, g_tx_buf, g_rx_buf,
			SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
		printf("Error: %s(): %d\n", __func__, __LINE__);
		return 0;
	}
	return g_rx_buf[0];
}

s32 spi_nor_cmd_1byte(struct spi_flash *flash, u8 cmd)
{
	g_tx_buf[0] = cmd;

	if (spi_xfer(flash->spi, (1 << 3), g_tx_buf, g_rx_buf,
			SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
		printf("Error: %s(): %d\n", __func__, __LINE__);
		return -1;
	}
	return 0;
}

struct spi_flash *spi_flash_probe(unsigned int bus, unsigned int cs,
				  unsigned int max_hz, unsigned int spi_mode)
{
	struct spi_slave *spi = NULL;
	const struct imx_spi_flash_vendor *vendor = NULL;
	struct imx_spi_flash *imx_sf = NULL;
	u8  idcode[4] = { 0 };
	int ret, i;

	if (CONFIG_SPI_FLASH_CS != cs) {
		printf("Invalid cs for SPI NOR.\n");
		return NULL;
	}

	spi = spi_setup_slave(bus, cs, max_hz, spi_mode);
	if (!spi) {
		printf("SF: Failed to set up slave\n");
		return NULL;
	}

	ret = spi_claim_bus(spi);
	if (ret) {
		printf("SF: Failed to claim SPI bus: %d\n", ret);
		goto err_claim_bus;
	}

	imx_sf = (struct imx_spi_flash *)malloc(sizeof(struct imx_spi_flash));
	if (!imx_sf) {
		printf("SF: Failed to allocate memory\n");
		goto err_malloc;
	}

	imx_sf->flash.spi = spi;

	/* Read the ID codes */
	ret = spi_nor_flash_query(&(imx_sf->flash), idcode);
	if (ret) {
		printf("SF: Failed reading SPI flash ID %d\n", ret);
		goto err_read_id;
	}

	for (i = 0; i < ARRAY_SIZE(imx_spi_flash_table); ++i) {
		vendor = &imx_spi_flash_table[i];
		if (vendor->mfr_id == idcode[0])
			break;
	}

	if (i == ARRAY_SIZE(imx_spi_flash_table)) {
		printf("SF: Unsupported vendor ID %02x\n", idcode[0]);
		goto err_read_id;
	}

	ret = vendor->probe(imx_sf, idcode);
	if (ret) {
		printf("SF: Vendor specific probe failed: %d\n", ret);
		goto err_read_id;
	}

	debug("SF: Detected %s with block size %lu, "
	      "block count %lu, total %u bytes\n",
	      imx_sf->params->name,
	      imx_sf->params->block_size,
	      imx_sf->params->block_count,
	      imx_sf->params->device_size);

	return &(imx_sf->flash);

err_read_id:
	free(imx_sf);
err_malloc:
	spi_release_bus(spi);
err_claim_bus:
	spi_free_slave(spi);

	return NULL;
}

void spi_flash_free(struct spi_flash *flash)
{
	struct imx_spi_flash *imx_sf = NULL;

	if (!flash)
		return;

	imx_sf = to_imx_spi_flash(flash);

	if (flash->spi) {
		spi_free_slave(flash->spi);
		flash->spi = NULL;
	}

	free(imx_sf);
}
