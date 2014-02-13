/*
 * Copyright (C) 2010-2012 Freescale Semiconductor, Inc.
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <common.h>
#include <i2c.h>
#include <mmc.h>

#include <asm/io.h>
#include <asm/errno.h>
#include <asm/gpio.h>
#include <asm/arch/gpio.h>
#include <asm/arch/mx6.h>
#include <asm/arch/mx6_pins.h>
#include <asm/arch/mx6dl_pins.h>
#include <asm/arch/iomux-v3.h>

#include <miiphy.h>

#include <imx_spi.h>
#include <fsl_esdhc.h>

#if defined(CONFIG_VIDEO_MX5)
#include <linux/list.h>
#include <linux/fb.h>
#include <linux/mxcfb.h>
#include <ipu.h>
#include <lcd.h>
#endif


DECLARE_GLOBAL_DATA_PTR;

static enum boot_device boot_dev;

#ifdef CONFIG_VIDEO_MX5
extern unsigned char fsl_bmp_600x400[];
extern int fsl_bmp_600x400_size;
extern int g_ipu_hw_rev;

#if defined(CONFIG_BMP_8BPP)
unsigned short colormap[256];
#elif defined(CONFIG_BMP_16BPP)
unsigned short colormap[65536];
#else
unsigned short colormap[16777216];
#endif

static int di = 1;

extern int ipuv3_fb_init(struct fb_videomode *mode, int di,
			int interface_pix_fmt,
			ipu_di_clk_parent_t di_clk_parent,
			int di_clk_val);

static struct fb_videomode lvds_xga = {
	 "XGA", 60, 1024, 768, 15385, 220, 40, 21, 7, 60, 10,
	 FB_SYNC_EXT,
	 FB_VMODE_NONINTERLACED,
	 0,
};

vidinfo_t panel_info;
#endif

static inline void setup_boot_device(void)
{
	uint soc_sbmr = readl(SRC_BASE_ADDR + 0x4);
	uint bt_mem_ctl = (soc_sbmr & 0x000000FF) >> 4 ;
	uint bt_mem_type = (soc_sbmr & 0x00000008) >> 3;

	switch (bt_mem_ctl) {
		case 0x0:
			if (bt_mem_type)
				boot_dev = ONE_NAND_BOOT;
			else
				boot_dev = WEIM_NOR_BOOT;
			break;
		case 0x2:
			boot_dev = SATA_BOOT;
			break;
		case 0x3:
			if (bt_mem_type)
				boot_dev = I2C_BOOT;
			else
				boot_dev = SPI_NOR_BOOT;
			break;
		case 0x4:
		case 0x5:
			boot_dev = SD_BOOT;
			break;
		case 0x6:
		case 0x7:
			boot_dev = MMC_BOOT;
			break;
		case 0x8 ... 0xf:
			boot_dev = NAND_BOOT;
			break;
		default:
			boot_dev = UNKNOWN_BOOT;
	}
}

enum boot_device get_boot_device(void)
{
	return boot_dev;
}

u32 get_board_rev(void)
{
	return 100;
}

#if defined(CONFIG_DWC_AHSATA)
#define ANATOP_PLL_LOCK                 0x80000000
#define ANATOP_PLL_ENABLE_MASK          0x00002000
#define ANATOP_PLL_BYPASS_MASK          0x00010000
#define ANATOP_PLL_LOCK                 0x80000000
#define ANATOP_PLL_PWDN_MASK            0x00001000
#define ANATOP_PLL_HOLD_RING_OFF_MASK   0x00000800
#define ANATOP_SATA_CLK_ENABLE_MASK     0x00100000

static int cm_fx6_setup_sata(void)
{
	u32 reg = 0;
	s32 timeout = 100000;

	/* Enable sata clock */
	reg = readl(CCM_BASE_ADDR + 0x7c); /* CCGR5 */
	reg |= 0x30;
	writel(reg, CCM_BASE_ADDR + 0x7c);

	/* Enable PLLs */
	reg = readl(ANATOP_BASE_ADDR + 0xe0); /* ENET PLL */
	reg &= ~ANATOP_PLL_PWDN_MASK;
	writel(reg, ANATOP_BASE_ADDR + 0xe0);
	reg |= ANATOP_PLL_ENABLE_MASK;

	while (timeout--) {
		if (readl(ANATOP_BASE_ADDR + 0xe0) & ANATOP_PLL_LOCK)
			break;
	}

	if (timeout <= 0)
		return -1;

	reg &= ~ANATOP_PLL_BYPASS_MASK;
	writel(reg, ANATOP_BASE_ADDR + 0xe0);
	reg |= ANATOP_SATA_CLK_ENABLE_MASK;
	writel(reg, ANATOP_BASE_ADDR + 0xe0);

	/* Enable sata phy */
	reg = readl(IOMUXC_BASE_ADDR + 0x34); /* GPR13 */

	reg &= ~0x07ffffff;
	/*
	 * rx_eq_val_0 = 5 [26:24]
	 * rx_los_lvl = 0x12 [23:19]
	 * rx_dpll_mode_0 = 0x3 [18:16]
	 * sata_speed = 0x0 [15]
	 * mpll_ss_en = 0x0 [14]
	 * tx_atten_0 = 0x4 [13:11]
	 * tx_boost_0 = 0x0 [10:7]
	 * tx_lvl = 0x11 [6:2]
	 * tx_edgerate_0 = 0x2 [1:0]
	 * */
	reg |= 0x5932046;
	writel(reg, IOMUXC_BASE_ADDR + 0x34);

	return 0;
}
#else
static inline int cm_fx6_setup_sata(void)
#endif /* CONFIG_DWC_AHSATA */

int dram_init(void)
{
	/*
	 * Switch PL301_FAST2 to DDR Dual-channel mapping
	 * however this block the boot up, temperory redraw
	 */
	/*
	 * u32 reg = 1;
	 * writel(reg, GPV0_BASE_ADDR);
	 */

	gd->bd->bi_dram[0].start = PHYS_SDRAM_1;
	gd->bd->bi_dram[0].size = PHYS_SDRAM_1_SIZE;
#if (CONFIG_NR_DRAM_BANKS == 2)
	gd->bd->bi_dram[1].start = PHYS_SDRAM_2;
	gd->bd->bi_dram[1].size = PHYS_SDRAM_2_SIZE;
#endif
	return 0;
}

#if defined CONFIG_MX6Q
static iomux_v3_cfg_t cm_fx6_uart4_pads[] = {
	MX6Q_PAD_KEY_COL0__UART4_TXD,
	MX6Q_PAD_KEY_ROW0__UART4_RXD,
};
#elif defined CONFIG_MX6DL
static iomux_v3_cfg_t cm_fx6_uart4_pads[] = {
	MX6DL_PAD_KEY_COL0__UART4_TXD,
	MX6DL_PAD_KEY_ROW0__UART4_RXD,
};
#endif /* CONFIG_MX6Q */

static void cm_fx6_setup_uart(void)
{
	mxc_iomux_v3_setup_multiple_pads(cm_fx6_uart4_pads,
					 ARRAY_SIZE(cm_fx6_uart4_pads));
}

#if defined CONFIG_I2C_MXC
#if defined CONFIG_MX6Q
static iomux_v3_cfg_t cm_fx6_i2c1_pads[] = {
	MX6Q_PAD_EIM_D21__I2C1_SCL,
	MX6Q_PAD_EIM_D28__I2C1_SDA,
};

static iomux_v3_cfg_t cm_fx6_i2c2_pads[] = {
	MX6Q_PAD_KEY_COL3__I2C2_SCL,
	MX6Q_PAD_KEY_ROW3__I2C2_SDA,
};

static iomux_v3_cfg_t cm_fx6_i2c3_pads[] = {
	MX6Q_PAD_GPIO_3__I2C3_SCL,
	MX6Q_PAD_GPIO_6__I2C3_SDA,
};
#elif defined CONFIG_MX6DL
static iomux_v3_cfg_t cm_fx6_i2c1_pads[] = {
	MX6DL_PAD_EIM_D21__I2C1_SCL,
	MX6DL_PAD_EIM_D28__I2C1_SDA,
};

static iomux_v3_cfg_t cm_fx6_i2c2_pads[] = {
	MX6DL_PAD_KEY_COL3__I2C2_SCL,
	MX6DL_PAD_KEY_ROW3__I2C2_SDA,
};

static iomux_v3_cfg_t cm_fx6_i2c3_pads[] = {
	MX6DL_PAD_GPIO_3__I2C3_SCL,
	MX6DL_PAD_GPIO_6__I2C3_SDA,
};
#endif /* CONFIG_MX6Q */

static void cm_fx6_setup_i2c(unsigned int module_base)
{
	unsigned int reg;

	switch (module_base) {
		case I2C1_BASE_ADDR:
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_i2c1_pads,
						 ARRAY_SIZE(cm_fx6_i2c1_pads));
			/* Enable i2c clock */
			reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR2);
			reg |= 0xC0;
			writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR2);
			break;
		case I2C2_BASE_ADDR:
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_i2c2_pads,
						 ARRAY_SIZE(cm_fx6_i2c2_pads));
			/* Enable i2c clock */
			reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR2);
			reg |= 0x300;
			writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR2);
			break;
		case I2C3_BASE_ADDR:
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_i2c3_pads,
						 ARRAY_SIZE(cm_fx6_i2c3_pads));
			/* Enable i2c clock */
			reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR2);
			reg |= 0xC00;
			writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR2);
			break;
		default:
			printf("Invalid I2C base: 0x%x\n", module_base);
	}
}
#else /* CONFIG_I2C_MXC */
static inline void cm_fx6_setup_i2c(unsigned int module_base) {}
#endif /* CONFIG_I2C_MXC */

#if defined(CONFIG_IMX_ECSPI)
s32 spi_get_cfg(struct imx_spi_dev_t *dev)
{
	switch (dev->slave.cs) {
	case 0:
		/* SPI-NOR */
		dev->base = ECSPI1_BASE_ADDR;
		dev->freq = 25000000;
		dev->ss_pol = IMX_SPI_ACTIVE_LOW;
		dev->ss = 0;
		dev->fifo_sz = 64 * 4;
		dev->us_delay = 0;
		break;
	case 1:
		/* SPI-NOR */
		dev->base = ECSPI1_BASE_ADDR;
		dev->freq = 25000000;
		dev->ss_pol = IMX_SPI_ACTIVE_LOW;
		dev->ss = 1;
		dev->fifo_sz = 64 * 4;
		dev->us_delay = 0;
		break;
	default:
		printf("Invalid Bus ID!\n");
	}

	return 0;
}

#if defined(CONFIG_MX6Q)
static iomux_v3_cfg_t cm_fx6_spi1_pads[] = {
	MX6Q_PAD_EIM_D16__ECSPI1_SCLK,
	MX6Q_PAD_EIM_D17__ECSPI1_MISO,
	MX6Q_PAD_EIM_D18__ECSPI1_MOSI,
	MX6Q_PAD_EIM_EB2__ECSPI1_SS0,
	MX6Q_PAD_EIM_D19__ECSPI1_SS1,
};
#elif defined(CONFIG_MX6DL)
static iomux_v3_cfg_t cm_fx6_spi1_pads[] = {
	MX6DL_PAD_EIM_D16__ECSPI1_SCLK,
	MX6DL_PAD_EIM_D17__ECSPI1_MISO,
	MX6DL_PAD_EIM_D18__ECSPI1_MOSI,
	MX6DL_PAD_EIM_EB2__ECSPI1_SS0,
	MX6DL_PAD_EIM_D19__ECSPI1_SS1,
};
#endif

void spi_io_init(struct imx_spi_dev_t *dev)
{
	u32 reg;

	switch (dev->base) {
		case ECSPI1_BASE_ADDR:
			/* Enable clock */
			reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR1);
			reg |= 0x3;
			writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR1);
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_spi1_pads,
						ARRAY_SIZE(cm_fx6_spi1_pads));
			break;
		case ECSPI2_BASE_ADDR:
		case ECSPI3_BASE_ADDR:
			/* ecspi2-3 fall through */
			break;
		default:;
	}
}
#endif /* CONFIG_IMX_ECSPI */

#if defined(CONFIG_NAND_GPMI)
#if defined(CONFIG_MX6Q)
static iomux_v3_cfg_t cm_fx6_nfc_pads[] = {
	MX6Q_PAD_NANDF_CLE__RAWNAND_CLE,
	MX6Q_PAD_NANDF_ALE__RAWNAND_ALE,
	MX6Q_PAD_NANDF_CS0__RAWNAND_CE0N,
	MX6Q_PAD_NANDF_RB0__RAWNAND_READY0,
	MX6Q_PAD_NANDF_D0__RAWNAND_D0,
	MX6Q_PAD_NANDF_D1__RAWNAND_D1,
	MX6Q_PAD_NANDF_D2__RAWNAND_D2,
	MX6Q_PAD_NANDF_D3__RAWNAND_D3,
	MX6Q_PAD_NANDF_D4__RAWNAND_D4,
	MX6Q_PAD_NANDF_D5__RAWNAND_D5,
	MX6Q_PAD_NANDF_D6__RAWNAND_D6,
	MX6Q_PAD_NANDF_D7__RAWNAND_D7,
	MX6Q_PAD_SD4_CMD__RAWNAND_RDN,
	MX6Q_PAD_SD4_CLK__RAWNAND_WRN,
};
#elif defined(CONFIG_MX6DL)
static iomux_v3_cfg_t cm_fx6_nfc_pads[] = {
	MX6DL_PAD_NANDF_CLE__RAWNAND_CLE,
	MX6DL_PAD_NANDF_ALE__RAWNAND_ALE,
	MX6DL_PAD_NANDF_CS0__RAWNAND_CE0N,
	MX6DL_PAD_NANDF_RB0__RAWNAND_READY0,
	MX6DL_PAD_NANDF_D0__RAWNAND_D0,
	MX6DL_PAD_NANDF_D1__RAWNAND_D1,
	MX6DL_PAD_NANDF_D2__RAWNAND_D2,
	MX6DL_PAD_NANDF_D3__RAWNAND_D3,
	MX6DL_PAD_NANDF_D4__RAWNAND_D4,
	MX6DL_PAD_NANDF_D5__RAWNAND_D5,
	MX6DL_PAD_NANDF_D6__RAWNAND_D6,
	MX6DL_PAD_NANDF_D7__RAWNAND_D7,
	MX6DL_PAD_SD4_CMD__RAWNAND_RDN,
	MX6DL_PAD_SD4_CLK__RAWNAND_WRN,
};
#endif /* CONFIG_MX6Q */

static void cm_fx6_setup_gpmi_nand(void)
{
	unsigned int reg;

	/* config gpmi nand iomux */
	mxc_iomux_v3_setup_multiple_pads(cm_fx6_nfc_pads,
					 ARRAY_SIZE(cm_fx6_nfc_pads));

	/* config gpmi and bch clock to 11Mhz*/
	reg = readl(CCM_BASE_ADDR + CLKCTL_CS2CDR);
	reg &= 0xF800FFFF;
	reg |= 0x01E40000;
	writel(reg, CCM_BASE_ADDR + CLKCTL_CS2CDR);

	/* enable gpmi and bch clock gating */
	reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR4);
	reg |= 0xFF003000;
	writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR4);

	/* enable apbh clock gating */
	reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR0);
	reg |= 0x0030;
	writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR0);
}
#else
static inline void cm_fx6_setup_gpmi_nand(void) {}
#endif /* CONFIG_NAND_GPMI */

#ifdef CONFIG_NET_MULTI
int board_eth_init(bd_t *bis)
{
	return -ENODEV;
}
#endif

#ifdef CONFIG_CMD_MMC
/*
 * CM-FX6 does not support the 1.8V signalling.
 * Last element in struct is used to indicate 1.8V support.
 */
static struct fsl_esdhc_cfg cm_fx6_usdhc_cfg[] = {
	{ USDHC1_BASE_ADDR, 1, 1, 1, 0 },
	{ USDHC2_BASE_ADDR, 1, 1, 1, 0 },
	{ USDHC3_BASE_ADDR, 1, 1, 1, 0 },
};

#if defined CONFIG_MX6Q
iomux_v3_cfg_t cm_fx6_usdhc1_pads[] = {
	MX6Q_PAD_SD1_CLK__USDHC1_CLK,
	MX6Q_PAD_SD1_CMD__USDHC1_CMD,
	MX6Q_PAD_SD1_DAT0__USDHC1_DAT0,
	MX6Q_PAD_SD1_DAT1__USDHC1_DAT1,
	MX6Q_PAD_SD1_DAT2__USDHC1_DAT2,
	MX6Q_PAD_SD1_DAT3__USDHC1_DAT3,
};

iomux_v3_cfg_t cm_fx6_usdhc2_pads[] = {
	MX6Q_PAD_SD2_CLK__USDHC2_CLK,
	MX6Q_PAD_SD2_CMD__USDHC2_CMD,
	MX6Q_PAD_SD2_DAT0__USDHC2_DAT0,
	MX6Q_PAD_SD2_DAT1__USDHC2_DAT1,
	MX6Q_PAD_SD2_DAT2__USDHC2_DAT2,
	MX6Q_PAD_SD2_DAT3__USDHC2_DAT3,
};

iomux_v3_cfg_t cm_fx6_usdhc3_pads[] = {
	MX6Q_PAD_SD3_CLK__USDHC3_CLK,
	MX6Q_PAD_SD3_CMD__USDHC3_CMD,
	MX6Q_PAD_SD3_DAT0__USDHC3_DAT0,
	MX6Q_PAD_SD3_DAT1__USDHC3_DAT1,
	MX6Q_PAD_SD3_DAT2__USDHC3_DAT2,
	MX6Q_PAD_SD3_DAT3__USDHC3_DAT3,
	MX6Q_PAD_SD3_DAT4__USDHC3_DAT4,
	MX6Q_PAD_SD3_DAT5__USDHC3_DAT5,
	MX6Q_PAD_SD3_DAT6__USDHC3_DAT6,
	MX6Q_PAD_SD3_DAT7__USDHC3_DAT7,
	MX6Q_PAD_GPIO_18__USDHC3_VSELECT,
};

#elif defined CONFIG_MX6DL
iomux_v3_cfg_t cm_fx6_usdhc1_pads[] = {
	MX6DL_PAD_SD1_CLK__USDHC1_CLK,
	MX6DL_PAD_SD1_CMD__USDHC1_CMD,
	MX6DL_PAD_SD1_DAT0__USDHC1_DAT0,
	MX6DL_PAD_SD1_DAT1__USDHC1_DAT1,
	MX6DL_PAD_SD1_DAT2__USDHC1_DAT2,
	MX6DL_PAD_SD1_DAT3__USDHC1_DAT3,
};

iomux_v3_cfg_t cm_fx6_usdhc2_pads[] = {
	MX6DL_PAD_SD2_CLK__USDHC2_CLK,
	MX6DL_PAD_SD2_CMD__USDHC2_CMD,
	MX6DL_PAD_SD2_DAT0__USDHC2_DAT0,
	MX6DL_PAD_SD2_DAT1__USDHC2_DAT1,
	MX6DL_PAD_SD2_DAT2__USDHC2_DAT2,
	MX6DL_PAD_SD2_DAT3__USDHC2_DAT3,
};

iomux_v3_cfg_t cm_fx6_usdhc3_pads[] = {
	MX6DL_PAD_SD3_CLK__USDHC3_CLK,
	MX6DL_PAD_SD3_CMD__USDHC3_CMD,
	MX6DL_PAD_SD3_DAT0__USDHC3_DAT0,
	MX6DL_PAD_SD3_DAT1__USDHC3_DAT1,
	MX6DL_PAD_SD3_DAT2__USDHC3_DAT2,
	MX6DL_PAD_SD3_DAT3__USDHC3_DAT3,
	MX6DL_PAD_SD3_DAT4__USDHC3_DAT4,
	MX6DL_PAD_SD3_DAT5__USDHC3_DAT5,
	MX6DL_PAD_SD3_DAT6__USDHC3_DAT6,
	MX6DL_PAD_SD3_DAT7__USDHC3_DAT7,
	MX6DL_PAD_GPIO_18__USDHC3_VSELECT,
};
#endif

static void cm_fx6_usdhc_init_pads(int usdhc_num)
{
	switch (usdhc_num) {
		case 0:
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_usdhc1_pads,
						ARRAY_SIZE(cm_fx6_usdhc1_pads));
			break;
		case 1:
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_usdhc2_pads,
						ARRAY_SIZE(cm_fx6_usdhc2_pads));
			break;
		case 2:
			mxc_iomux_v3_setup_multiple_pads(cm_fx6_usdhc3_pads,
						ARRAY_SIZE(cm_fx6_usdhc3_pads));
			break;
		default:;
	}
}

static int cm_fx6_usdhc_init(bd_t *bis)
{
	int i, err = 0;

	for (i = 0; i < ARRAY_SIZE(cm_fx6_usdhc_cfg); ++i) {
		cm_fx6_usdhc_init_pads(i);
		if (fsl_esdhc_initialize(bis, &cm_fx6_usdhc_cfg[i])) {
			printf("%s: failed initializing USDHC%d!\n",
			       __func__, i + 1);
			err |= (1 << i);
		}
	}

	return err;
}

int board_mmc_init(bd_t *bis)
{
	if (cm_fx6_usdhc_init(bis) == 0x7) /* All USDHCs failed to initialize */
		return -1;

	return 0;
}
#endif /* CONFIG_CMD_MMC */

#ifdef CONFIG_LCD
void lcd_enable(void)
{
	char *s;
	int ret;
	unsigned int reg;

	s = getenv("lvds_num");
	di = simple_strtol(s, NULL, 10);

	/*
	* hw_rev 2: IPUV3DEX
	* hw_rev 3: IPUV3M
	* hw_rev 4: IPUV3H
	*/
	g_ipu_hw_rev = IPUV3_HW_REV_IPUV3H;

	/* set GPIO_9 to high so that backlight control could be high */
#if defined CONFIG_MX6Q
	mxc_iomux_v3_setup_pad(MX6Q_PAD_GPIO_9__GPIO_1_9);
#elif defined CONFIG_MX6DL
	mxc_iomux_v3_setup_pad(MX6DL_PAD_GPIO_9__GPIO_1_9);
#endif
	reg = readl(GPIO1_BASE_ADDR + GPIO_GDIR);
	reg |= (1 << 9);
	writel(reg, GPIO1_BASE_ADDR + GPIO_GDIR);

	reg = readl(GPIO1_BASE_ADDR + GPIO_DR);
	reg |= (1 << 9);
	writel(reg, GPIO1_BASE_ADDR + GPIO_DR);

	/* Enable IPU clock */
	if (di == 1) {
		reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR3);
		reg |= 0xC033;
		writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR3);
	} else {
		reg = readl(CCM_BASE_ADDR + CLKCTL_CCGR3);
		reg |= 0x300F;
		writel(reg, CCM_BASE_ADDR + CLKCTL_CCGR3);
	}

	ret = ipuv3_fb_init(&lvds_xga, di, IPU_PIX_FMT_RGB666,
			DI_PCLK_LDB, 65000000);
	if (ret)
		puts("LCD cannot be configured\n");

	reg = readl(ANATOP_BASE_ADDR + 0xF0);
	reg &= ~0x00003F00;
	reg |= 0x00001300;
	writel(reg, ANATOP_BASE_ADDR + 0xF4);

	reg = readl(CCM_BASE_ADDR + CLKCTL_CS2CDR);
	reg &= ~0x00007E00;
	reg |= 0x00003600;
	writel(reg, CCM_BASE_ADDR + CLKCTL_CS2CDR);

	reg = readl(CCM_BASE_ADDR + CLKCTL_CSCMR2);
	reg |= 0x00000C00;
	writel(reg, CCM_BASE_ADDR + CLKCTL_CSCMR2);

	reg = 0x0002A953;
	writel(reg, CCM_BASE_ADDR + CLKCTL_CHSCCDR);

	if (di == 1)
		writel(0x40C, IOMUXC_BASE_ADDR + 0x8);
	else
		writel(0x201, IOMUXC_BASE_ADDR + 0x8);
}
#endif

#ifdef CONFIG_VIDEO_MX5
void panel_info_init(void)
{
	panel_info.vl_bpix = LCD_BPP;
	panel_info.vl_col = lvds_xga.xres;
	panel_info.vl_row = lvds_xga.yres;
	panel_info.cmap = colormap;
}
#endif

#ifdef CONFIG_SPLASH_SCREEN
void setup_splash_image(void)
{
	char *s;
	ulong addr;

	s = getenv("splashimage");

	if (s != NULL) {
		addr = simple_strtoul(s, NULL, 16);
		memcpy((char *)addr, (char *)fsl_bmp_600x400,
				fsl_bmp_600x400_size);
	}
}
#endif

int board_init(void)
{
	mxc_iomux_v3_init((void *)IOMUXC_BASE_ADDR);
	setup_boot_device();

	/* board id for linux */
	gd->bd->bi_arch_number = MACH_TYPE_CM_FX6;

	/* address of boot parameters */
	gd->bd->bi_boot_params = PHYS_SDRAM_1 + 0x100;

	cm_fx6_setup_uart();
	cm_fx6_setup_sata();
	cm_fx6_setup_gpmi_nand();

#ifdef CONFIG_VIDEO_MX5
	panel_info_init();

	gd->fb_base = CONFIG_FB_BASE;
#endif
	return 0;
}

#ifdef CONFIG_ANDROID_RECOVERY

int check_recovery_cmd_file(void)
{
	/*not realized*/
	return 0;
}
#endif

int board_late_init(void)
{
	cm_fx6_setup_i2c(CONFIG_SYS_I2C_PORT);

	return 0;
}

#ifdef CONFIG_MXC_FEC
static int phy_read(char *devname, unsigned char addr, unsigned char reg,
		    unsigned short *pdata)
{
	int ret = miiphy_read(devname, addr, reg, pdata);
	if (ret)
		printf("Error reading from %s PHY addr=%02x reg=%02x\n",
		       devname, addr, reg);
	return ret;
}

static int phy_write(char *devname, unsigned char addr, unsigned char reg,
		     unsigned short value)
{
	int ret = miiphy_write(devname, addr, reg, value);
	if (ret)
		printf("Error writing to %s PHY addr=%02x reg=%02x\n", devname,
		       addr, reg);
	return ret;
}

int mx6_rgmii_rework(char *devname, int phy_addr)
{
	unsigned short val;

	/* To enable AR8031 ouput a 125MHz clk from CLK_25M */
	phy_write(devname, phy_addr, 0xd, 0x7);
	phy_write(devname, phy_addr, 0xe, 0x8016);
	phy_write(devname, phy_addr, 0xd, 0x4007);
	phy_read(devname, phy_addr, 0xe, &val);

	val &= 0xffe3;
	val |= 0x18;
	phy_write(devname, phy_addr, 0xe, val);

	/* introduce tx clock delay */
	phy_write(devname, phy_addr, 0x1d, 0x5);
	phy_read(devname, phy_addr, 0x1e, &val);
	val |= 0x0100;
	phy_write(devname, phy_addr, 0x1e, val);

	return 0;
}

#if defined CONFIG_MX6Q
iomux_v3_cfg_t enet_pads[] = {
	MX6Q_PAD_ENET_MDIO__ENET_MDIO,
	MX6Q_PAD_ENET_MDC__ENET_MDC,
	MX6Q_PAD_RGMII_TXC__ENET_RGMII_TXC,
	MX6Q_PAD_RGMII_TD0__ENET_RGMII_TD0,
	MX6Q_PAD_RGMII_TD1__ENET_RGMII_TD1,
	MX6Q_PAD_RGMII_TD2__ENET_RGMII_TD2,
	MX6Q_PAD_RGMII_TD3__ENET_RGMII_TD3,
	MX6Q_PAD_RGMII_TX_CTL__ENET_RGMII_TX_CTL,
	MX6Q_PAD_ENET_REF_CLK__ENET_TX_CLK,
	MX6Q_PAD_RGMII_RXC__ENET_RGMII_RXC,
	MX6Q_PAD_RGMII_RD0__ENET_RGMII_RD0,
	MX6Q_PAD_RGMII_RD1__ENET_RGMII_RD1,
	MX6Q_PAD_RGMII_RD2__ENET_RGMII_RD2,
	MX6Q_PAD_RGMII_RD3__ENET_RGMII_RD3,
	MX6Q_PAD_RGMII_RX_CTL__ENET_RGMII_RX_CTL,
	MX6Q_PAD_GPIO_0__CCM_CLKO,
	MX6Q_PAD_GPIO_3__CCM_CLKO2,
};
#elif defined CONFIG_MX6DL
iomux_v3_cfg_t enet_pads[] = {
	MX6DL_PAD_ENET_MDIO__ENET_MDIO,
	MX6DL_PAD_ENET_MDC__ENET_MDC,
	MX6DL_PAD_RGMII_TXC__ENET_RGMII_TXC,
	MX6DL_PAD_RGMII_TD0__ENET_RGMII_TD0,
	MX6DL_PAD_RGMII_TD1__ENET_RGMII_TD1,
	MX6DL_PAD_RGMII_TD2__ENET_RGMII_TD2,
	MX6DL_PAD_RGMII_TD3__ENET_RGMII_TD3,
	MX6DL_PAD_RGMII_TX_CTL__ENET_RGMII_TX_CTL,
	MX6DL_PAD_ENET_REF_CLK__ENET_TX_CLK,
	MX6DL_PAD_RGMII_RXC__ENET_RGMII_RXC,
	MX6DL_PAD_RGMII_RD0__ENET_RGMII_RD0,
	MX6DL_PAD_RGMII_RD1__ENET_RGMII_RD1,
	MX6DL_PAD_RGMII_RD2__ENET_RGMII_RD2,
	MX6DL_PAD_RGMII_RD3__ENET_RGMII_RD3,
	MX6DL_PAD_RGMII_RX_CTL__ENET_RGMII_RX_CTL,
	MX6DL_PAD_GPIO_0__CCM_CLKO,
	MX6DL_PAD_GPIO_3__CCM_CLKO2,
};
#endif

void enet_board_init(void)
{
	unsigned int reg;
	iomux_v3_cfg_t enet_reset;
#if defined CONFIG_MX6Q
	enet_reset = (MX6Q_PAD_KEY_ROW4__GPIO_4_15 &
			~MUX_PAD_CTRL_MASK)           |
			 MUX_PAD_CTRL(0x84);
#elif defined CONFIG_MX6DL
	enet_reset = (MX6DL_PAD_KEY_ROW4__GPIO_4_15 &
			~MUX_PAD_CTRL_MASK)           |
			 MUX_PAD_CTRL(0x84);
#endif
	mxc_iomux_v3_setup_multiple_pads(enet_pads,
			ARRAY_SIZE(enet_pads));

	mxc_iomux_v3_setup_pad(enet_reset);

	/* phy reset: gpio4-15 */
	reg = readl(GPIO4_BASE_ADDR + 0x0);
	reg &= ~0x8000;
	writel(reg, GPIO4_BASE_ADDR + 0x0);

	reg = readl(GPIO4_BASE_ADDR + 0x4);
	reg |= 0x8000;
	writel(reg, GPIO4_BASE_ADDR + 0x4);

	udelay(500);

	reg = readl(GPIO4_BASE_ADDR + 0x0);
	reg |= 0x8000;
	writel(reg, GPIO4_BASE_ADDR + 0x0);
}
#endif

int checkboard(void)
{
	u32 reg;

	/* turn on the green LED */
	reg = readl(GPIO2_BASE_ADDR + GPIO_GDIR);
	reg |= 0x80000000;
	writel(reg, GPIO2_BASE_ADDR + GPIO_GDIR);

	reg = readl(GPIO2_BASE_ADDR + GPIO_DR);
	reg |= 0x80000000;
	writel(reg, GPIO2_BASE_ADDR + GPIO_DR);

	printf("Board: CM-FX6:[ ");

	switch (__REG(SRC_BASE_ADDR + 0x8)) {
	case 0x0001:
		printf("POR");
		break;
	case 0x0009:
		printf("RST");
		break;
	case 0x0010:
	case 0x0011:
		printf("WDOG");
		break;
	default:
		printf("unknown");
	}
	printf(" ]\n");

	printf("Boot Device: ");
	switch (get_boot_device()) {
	case WEIM_NOR_BOOT:
		printf("NOR\n");
		break;
	case ONE_NAND_BOOT:
		printf("ONE NAND\n");
		break;
	case PATA_BOOT:
		printf("PATA\n");
		break;
	case SATA_BOOT:
		printf("SATA\n");
		break;
	case I2C_BOOT:
		printf("I2C\n");
		break;
	case SPI_NOR_BOOT:
		printf("SPI NOR\n");
		break;
	case SD_BOOT:
		printf("SD\n");
		break;
	case MMC_BOOT:
		printf("MMC\n");
		break;
	case NAND_BOOT:
		printf("NAND\n");
		break;
	case UNKNOWN_BOOT:
	default:
		printf("UNKNOWN\n");
		break;
	}

#ifdef CONFIG_SECURE_BOOT
	if (check_hab_enable() == 1)
		get_hab_status();
#endif

	return 0;
}


#ifdef CONFIG_IMX_UDC

#define USB_H1_POWER  IMX_GPIO_NR(3, 31)
#define USB_OTG_PWR0  IMX_GPIO_NR(3, 22)
#define USB_OTG_PWR1  IMX_GPIO_NR(4, 15)

void udc_pins_setting(void)
{
	mxc_iomux_v3_setup_pad(MX6X_IOMUX(PAD_GPIO_1__USBOTG_ID));
	mxc_iomux_set_gpr_register(1, 13, 1, 1);

	/*USB_HOST_VBUS  EIM_D31                         LED D5*/
	gpio_direction_output(USB_H1_POWER, 1);
	mxc_iomux_v3_setup_pad(MX6X_IOMUX(PAD_EIM_D31__GPIO_3_31));

	/*USB_OTG_VBUS  EIM_D22   KEY_ROW4               LED D6*/
	/* there are two pads to control OTG power supply, but only one pads
	acturally used, in case of different hardware setting, two pads
	function as gpio, and set to 0.
	In case of 1-pluse when set the pad as gpio, set the pad to 0 before
	setting it as gpio*/
	gpio_direction_output(USB_OTG_PWR0, 0);
	mxc_iomux_v3_setup_pad(MX6X_IOMUX(PAD_EIM_D22__GPIO_3_22));

	gpio_direction_output(USB_OTG_PWR1, 0);
	mxc_iomux_v3_setup_pad(MX6X_IOMUX(PAD_KEY_ROW4__GPIO_4_15));
}
#endif
