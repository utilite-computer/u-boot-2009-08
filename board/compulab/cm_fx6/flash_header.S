/*
 * Copyright (C) 2013-2014 CompuLab, Ltd.
 *
 * Author: Igor Grinberg <grinberg@compulab.co.il>
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
 * Foundation, Inc.
 */

#include <config.h>
#include <asm/arch/mx6.h>

#ifdef	CONFIG_FLASH_HEADER
#ifndef CONFIG_FLASH_HEADER_OFFSET
# error "CONFIG_FLASH_HEADER_OFFSET must be defined!"
#endif

/********************DCD mode***********************/
#define CPU_2_BE_32(l) \
	((((l) & 0x000000FF) << 24) | \
	 (((l) & 0x0000FF00) << 8)  | \
	 (((l) & 0x00FF0000) >> 8)  | \
	 (((l) & 0xFF000000) >> 24))

#define MXC_DCD_ITEM(i, addr, val)	\
dcd_node_##i:				\
	.word CPU_2_BE_32(addr);	\
	.word CPU_2_BE_32(val);

.section ".text.flasheader", "x"
	b	_start
	.org	CONFIG_FLASH_HEADER_OFFSET

ivt_header:		.word 0x402000D1 /* Tag=0xD1, Len=0x0020, Ver=0x40 */
app_code_jump_v:	.word _start
reserv1:		.word 0x0
dcd_ptr:		.word dcd_hdr
boot_data_ptr:		.word boot_data
self_ptr:		.word ivt_header
app_code_csf:		.word 0x0
reserv2:		.word 0x0

boot_data:	.word TEXT_BASE
image_len:	.word _end_of_copy - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
plugin:		.word 0x0

#ifdef CONFIG_MX6SOLO_DDR3
/* i.MX6 Dual Lite/Solo DDR3 configuration */

/* Tag=0xD2, Len=80*8 + 2*4 + 1*4 + 4, Ver=0x41 */
dcd_hdr:	.word 0x419002D2
write_dcd_cmd:	.word 0x043C01CC /* Tag=0xCC, Len=39*8 + 4, Param=0x04 */

/* DCD */
/* IOMUXC_BASE_ADDR  = 0x20e0000 */

/* SDQS[0-7]_P
 * DSE	= 0x7 (34OHM)
 * ODT	= 0 (disabled)
 * PKE	= 0 (disabled)
 * PUE	= 0 (keeper)
 * PUS	= 0 (100K OHM PD)
 */
MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x4bc, 0x00000038)
MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x4c0, 0x00000038)
MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x4c4, 0x00000038)
MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x4c8, 0x00000038)
MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x4cc, 0x00000038)
MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x4d0, 0x00000038)
MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x4d4, 0x00000038)
MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x4d8, 0x00000038)

/* DQM[0-7] */
MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x470, 0x00000038)
MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x474, 0x00000038)
MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x478, 0x00000038)
MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x47c, 0x00000038)
MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x480, 0x00000038)
MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x484, 0x00000038)
MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x488, 0x00000038)
MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x48c, 0x00000038)

/* CAS, RAS */
MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x464, 0x00000038)
MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x490, 0x00000038)

/* Clocks: SDCLK0_P, SDCLK1_P */
MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x4ac, 0x00000038)
MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x4b0, 0x00000038)

/*
 * Below DRAM_RESET[DDR_SEL] = 0 which is incorrect according to
 * Freescale SDLRM, but this is exactly the value used by the automatic
 * calibration script and it works also in all our tests, so we leave
 * it as is at this point.
 */
/* Control: RESET, SDBA2 */
MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x494, 0x00000038)
MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x4a0, 0x00000000)

/* Control: ODT0, ODT1 */
MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x4b4, 0x00000038)
MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x4b8, 0x00000038)

/* B[0-7]DS */
MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x764, 0x00000038)
MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x770, 0x00000038)
MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x778, 0x00000038)
MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x77c, 0x00000038)
MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x780, 0x00000038)
MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x784, 0x00000038)
MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x78c, 0x00000038)
MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x748, 0x00000038)

/* ADDDS - Address lines Drive Strength */
MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x74c, 0x00000038)

/* DDRMODE_CTL */
MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x750, 0x00020000)

/* DDRPKE
 * PKE	= 0 (pull disabled)
 */
MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x754, 0x00000000)

/* DDRMODE */
MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x760, 0x00020000)

/* CTLDS */
MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x76c, 0x00000038)

/* DDR IO TYPE */
MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x774, 0x000C0000)

/* MMDC_P0_BASE_ADDR = 0x021b0000 */
/* MMDC_P1_BASE_ADDR = 0x021b4000 */

/* ----- One time ZQ calibration start ----- */
/* MPZQHWCTRL
 * ZQ_MODE	= 0x3 (ZQ calibr. both: i.MX & DDR device on SR exit & periodic)
 * ZQ_HW_PER	= 0 (every 1ms)
 * ZQ_HW_PU_RES	= 0 (ro)
 * ZQ_HW_PD_RES	= 0 (ro)
 * ZQ_HW_FOR	= 1 (force ZQ calibration)
 * TZQ_INIT	= 0x4 (512 cycles - default JEDEC value for DDR3)
 * TZQ_OPER	= 0x3 (256 cycles - default JEDEC value for DDR3)
 * TZQ_CS	= 0x2 (128 cycles - default)
 * ZQ_EARLY_COMPARATOR_EN_TIMER	= 0x14 (21 cycles - default)
 */
MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x800, 0xA1390003)

/* Wait for ZQ_HW_FOR to finish the calibration on both MMDCs */
poll_dcd_cmd1: .word 0x040C00CF /* Tag=0xCF, Len=1*8 + 4, Param=0x04 */
MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x800, 0x00010000)
/* ----- One time ZQ calibration end ----- */

write_dcd_cmd2:	.word 0x044401CC /* Tag=0xCC, Len=40*8 + 4, Param=0x04 */

/* MPWLDECTRL[0-1] - write leveling preset values from calibration */
MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x80c, 0x005B0061)
MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x810, 0x004F0055)

/* MPDGCTRL[0-1] - read DQS gating preset values from calibration */
MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x83c, 0x0314030C)
MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x840, 0x025C0268)

/* MPRDDLCTL - read delay lines preset values from calibration */
MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x848, 0x42464646)

/* MPWRDLCTL - write delay lines preset values from calibration */
MXC_DCD_ITEM(46, MMDC_P0_BASE_ADDR + 0x850, 0x36322C34)

/* MMDC1_MPRDDQBY[0-3]DL
 * rd_dq[0-7]_del	= 0x3 (3 delay units - recommended value)
 */
MXC_DCD_ITEM(47, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

/* MMDC2_MPRDDQBY[0-3]DL
 * rd_dq[0-7]_del	= 0x3 (3 delay units - recommended value)
 */
MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(52, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(53, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(54, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

/* MPMUR0
 * MU_BYP_VAL	= 0 (irrelevant for normal use)
 * MU_BYP_EN	= 0 (irrelevant for normal use: use MU_UNIT_DEL_NUM)
 * FRC_MSR	= 1 (complete calibration by forced measurement)
 * MU_UNIT_DEL_NUM	= 0 (irrelevant for normal use)
 */
MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)

/* MDPDC
 * tCKSRE	= 0x5 (5 cycles)
 * tCKSRX	= 0x5 (5 cycles)
 * BOTH_CS_PD	= 0 (independent PD)
 * SLOW_PD	= 0 (fast mode)
 * PWDT_0	= 0 (disabled)
 * PWDT_1	= 0 (disabled)
 * tCKE		= 0x2 (3 cycles)
 * PRCT_0	= 0 (disabled)
 * PRCT_1	= 0 (disabled)
 */
MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x004, 0x0002002D)

/* MDOTC
 * tODT_idle_off	= 0x4 (4 cycles)
 * tODTLon		= 0x4 (4 cycles)
 * tAXPD		= 0x4 (5CK)
 * tANPD		= 0x4 (5CK)
 * tAONPD		= 0x3 (4 cycles) ?
 * tAOFPD		= 0x3 (4 cycles) ?
 */
MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x008, 0x1B444040)

/* MDCFG0
 * tRFC	  = 0x67 (104CK = ~260ns)
 * tXS	  = 0x6B (108CK = ~270ns)
 * tXP	  = 0x2 (3CK = ~7.5ns)
 * tXPDDL = 0x9 (10CK = ~25ns)
 * tFAW	  = 0x13 (20CK  = ~50ns)
 * tCL	  = 0x5 (8 cycles)
 */
MXC_DCD_ITEM(58, MMDC_P0_BASE_ADDR + 0x00c, 0x676B5335)

/* MDCFG1
 * tCWL	  = 0x4 (6 cycles)
 * tMRD	  = 0xB (12CK = ~22.5ns)
 * tWR	  = 0x7 (8 cycles = 15ns)
 * tRPA	  = 0x1 (tRP + 1)
 * tRAS	  = 0xE (15CK = 37.5ns)
 * tRC	  = 0x14 (21CK = 52.5ns)
 * tRP	  = 0x5 (6CK = 15ns)
 * tRCD	  = 0x5 (6CK = 15ns)
 */
MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x010, 0xB68E8F64)

/* MDCFG2
 * tRRD	  = 0x3 (4 cycles = 10ns)
 * tWTR	  = 0x3 (4 cycles = 7.5ns)
 * tRTP	  = 0x3 (4 cycles = 7.5ns)
 * tDLLK  = 0x1FF (JEDEC value for DDR3: 512 cycles = 960ns)
 */
MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

/* MDMISC
 * RST		= 0 (no reset)
 * LPDDR2_2CH	= 0 (DDR3 mode)
 * DDR_TYPE	= 0 (DDR3 mode)
 * DDR_4_BANK	= 0 (8 banks)
 * RALAT	= 0x5 cycles
 * MIF3_MODE	= 0x3
 * LPDDR2_S2	= 0 (DDR3)
 * BI_ON	= 0x1 (banks interleave on)
 * WALAT	= 0x1 (1 cycles)
 * LHD		= 0 (Latency hiding on)
 * ADDR_MIRROR	= 0x1
 * CALIB_PER_CS	= 0 (Calib target CS0)
 */
MXC_DCD_ITEM(61, MMDC_P0_BASE_ADDR + 0x018, 0x00091740)

/* MDSCR */
/* Set CON_REQ - configuration request */
MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)

/* MDRWD
 * RTR_DIFF	= 0x2 (2 cycles - Default)
 * RTW_DIFF	= 0x2 (2 cycles - Default)
 * WTW_DIFF	= 0x3 (3 cycles - Default)
 * WTR_DIFF	= 0x3 (3 cycles - Default)
 * RTW_SAME	= 0x2 (2 cycles - Default)
 * tDAI		= 0 (1 cycle - irrelevant for DDR3)
 */
MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)

/* MDOR
 * RST_to_CKE	= 0x23 (33 cycles - JEDEC for DDR3 - 500us)
 * SDE_to_RST	= 0x10 (14 cycles - JEDEC for DDR3 - 200us)
 * tXPR		= 0x6B (108 cycles = tRFC + 10ns)
 */
MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x030, 0x006B1023)

/* MDCTL - configure physical DRAM parameters */
#if defined(CONFIG_DDR_16BIT)
/* DSIZ = 0 (16), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & !CS1 */
MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x000, 0x83180000)
#elif defined(CONFIG_DDR_32BIT_512MB)
/* DSIZ = 0x1 (32), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & !CS1 */
MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x000, 0x83190000)
#elif defined(CONFIG_DDR_32BIT_1GB)
/* DSIZ = 0x1 (32), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & CS1 */
MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x000, 0xC3190000)
#else
# error "DRAM data bus width must be defined!"
#endif /* CONFIG_DDR_16BIT */

/* MDSCR
 * CMD_BA	= 0x2 (MR2)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0x8 (CWL = 0x1, ASR = 0, SRT = 0)
 * CMD_ADDR_MSB_MR_OP	= 0 (RTT(WR) = 0 is Micron recommended value)
 */
MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x01c, 0x00088032)
MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x01c, 0x0008803A)

/* MDSCR
 * CMD_BA	= 0x3 (MR3)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0 (MPR_RF = 0, MPR = 0)
 * CMD_ADDR_MSB_MR_OP	= 0 (reserved)
 */
MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)
MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x01c, 0x0000803B)

/* MDSCR
 * CMD_BA	= 0x1 (MR1)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0 (DLL = 0, ODS = 0x1 (34OHM),
 *	RTT[0-1] = 0x1 (60OHM), AL = 0, WL = 0)
 * CMD_ADDR_MSB_MR_OP	= 0 (RTT[2] = 0, TDQS = 0, QOff = 0 (enabled))
 */
MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x01c, 0x00068031)
MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x01c, 0x00068039)

/* MDSCR
 * CMD_BA	= 0 (MR0)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0x40 (BL = 0, CL = 0x8 (8 cycles), BT = 0)
 * CMD_ADDR_MSB_MR_OP	= 0x9 (DLL = 1 (reset DLL), WR = 0x4 (8), PD = 0)
 */
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)
MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x09408038)

/* MDSCR
 * CMD_BA	= 0 (ignored )
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x4 (ZQ calibration)
 * WL_EN	= 0 (ignored)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0 (must be 0)
 * CMD_ADDR_MSB_MR_OP	= 0x4 (can be 0 for ZQCS or 0x4 for ZQCL)
 */
MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)
MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x04008048)

/* MDREF
 * START_REF	= 0 (do not start a refresh cycle)
 * REFR		= 0x7 (8 refreshes) ?
 * REF_SEL	= 0x1 (use 32KHz)
 * REF_CNT	= 0 (not used)
 */
MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

/* MPODTCTRL
 * ODT_WR_PAS_EN	= 0x1 (Inactive CS ODT enabled during write)
 * ODT_WR_ACT_EN	= 0x1 (Active CS ODT enabled during write)
 * ODT_RD_PAS_EN	= 0x1 (Inactive CS ODT enabled during read)
 * ODT_RD_ACT_EN	= 0 (Active CS ODT disabled during read)
 * ODT0_INT_RES		= 0x2 (i.MX RTT for byte 0/4 - 60OHM)
 * ODT1_INT_RES		= 0x2 (i.MX RTT for byte 1/5 - 60OHM)
 * ODT2_INT_RES		= 0x2 (i.MX RTT for byte 2/6 - 60OHM)
 * ODT3_INT_RES		= 0x2 (i.MX RTT for byte 3/7 - 60OHM)
 */
MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)

/* MDPDC
 * tCKSRE	= 0x5 (5 cycles)
 * tCKSRX	= 0x5 (5 cycles)
 * BOTH_CS_PD	= 0x1
 * SLOW_PD	= 0x1 (slow mode)
 * PWDT_0	= 0x5 (256 cycles)
 * PWDT_1	= 0x5 (256 cycles)
 * tCKE		= 0x2 (3 cycles)
 * PRCT_0	= 0 (disabled) ?
 * PRCT_1	= 0 (disabled) ?
 */
MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x004, 0x000255ED)

/* MAPSR
 * PSD		= 0 (enabled)
 * PSS		= 0 (ro)
 * RIS		= 0 (ro)
 * WIS		= 0 (ro)
 * PST		= 0x10 (1024 cycles)
 * LPMD		= 0 (do not request lpmd)
 * DVFS		= 0 (do not request dvfs)
 * LPACK	= 0 (ro)
 * DVACK	= 0 (ro)
 */
MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x404, 0x00001006)

/* MDSCR - leave configuration mode */
MXC_DCD_ITEM(80, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

#else /* CONFIG_MX6SOLO_DDR3 configuration */
/* i.MX6 Quad/Dual DDR3 */

/* Tag=0xD2, Len=88*8 + 2*4 + 1*4 + 4, Ver=0x41 */
dcd_hdr:	.word 0x41D002D2
write_dcd_cmd1:	.word 0x043C01CC /* Tag=0xCC, Len=39*8 + 4, Param=0x04 */

/* DCD */
/* IOMUXC_BASE_ADDR  = 0x20e0000 */

/* SDQS[0-7]_P
 * DSE	= 0x7 (34OHM)
 * ODT	= 0 (disabled)
 * PKE	= 0 (disabled)
 * PUE	= 0 (keeper)
 * PUS	= 0 (100K OHM PD)
 */
MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x5a8, 0x00000038)
MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x5b0, 0x00000038)
MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x524, 0x00000038)
MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x51c, 0x00000038)
MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x518, 0x00000038)
MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x50c, 0x00000038)
MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x5b8, 0x00000038)
MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x5c0, 0x00000038)

/* DQM[0-7] */
MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x5ac, 0x00000038)
MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x5b4, 0x00000038)
MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x528, 0x00000038)
MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x520, 0x00000038)
MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x514, 0x00000038)
MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x510, 0x00000038)
MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x5bc, 0x00000038)
MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x5c4, 0x00000038)

/* CAS, RAS */
MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x56c, 0x00000038)
MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x578, 0x00000038)

/* Clocks: SDCLK0_P, SDCLK1_P */
MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x588, 0x00000038)
MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x594, 0x00000038)

/*
 * Below DRAM_RESET[DDR_SEL] = 0 which is incorrect according to
 * Freescale QRM, but this is exactly the value used by the automatic
 * calibration script and it works also in all our tests, so we leave
 * it as is at this point.
 */
/* Control: RESET, SDBA2 */
MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x57c, 0x00000038)
MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x58c, 0x00000000)

/* Control: ODT0, ODT1 */
MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x59c, 0x00000038)
MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x5a0, 0x00000038)

/* B[0-7]DS */
MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x784, 0x00000038)
MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x788, 0x00000038)
MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x794, 0x00000038)
MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x79c, 0x00000038)
MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x7a0, 0x00000038)
MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x7a4, 0x00000038)
MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x7a8, 0x00000038)
MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x748, 0x00000038)

/* ADDDS - Address lines Drive Strength */
MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x74c, 0x00000038)

/* DDRMODE_CTL */
MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x750, 0x00020000)

/* DDRPKE
 * PKE	= 0 (pull disabled)
 */
MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x758, 0x00000000)

/* DDRMODE */
MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x774, 0x00020000)

/* CTLDS */
MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x78c, 0x00000038)

/* DDR IO TYPE */
MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x798, 0x000C0000)

/* MMDC_P0_BASE_ADDR = 0x021b0000 */
/* MMDC_P1_BASE_ADDR = 0x021b4000 */

/* ----- One time ZQ calibration start ----- */
/* MPZQHWCTRL
 * ZQ_MODE	= 0x3 (ZQ calibr. both: i.MX & DDR device on SR exit & periodic)
 * ZQ_HW_PER	= 0 (every 1ms)
 * ZQ_HW_PU_RES	= 0 (ro)
 * ZQ_HW_PD_RES	= 0 (ro)
 * ZQ_HW_FOR	= 1 (force ZQ calibration)
 * TZQ_INIT	= 0x4 (512 cycles - default JEDEC value for DDR3)
 * TZQ_OPER	= 0x3 (256 cycles - default JEDEC value for DDR3)
 * TZQ_CS	= 0x2 (128 cycles - default)
 * ZQ_EARLY_COMPARATOR_EN_TIMER	= 0x14 (21 cycles - default)
 */
MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x800, 0xA1390003)

/* Wait for ZQ_HW_FOR to finish the calibration on both MMDCs */
poll_dcd_cmd1: .word 0x040C00CF /* Tag=0xCF, Len=1*8 + 4, Param=0x04 */
MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x800, 0x00010000)
/* ----- One time ZQ calibration end ----- */

write_dcd_cmd2:	.word 0x048401CC /* Tag=0xCC, Len=48*8 + 4, Param=0x04 */

/* MPWLDECTRL[0-1] - write leveling preset values from calibration */
MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x80c, 0x00630068)
MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x810, 0x0068005D)
MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x80c, 0x0035004C)
MXC_DCD_ITEM(44, MMDC_P1_BASE_ADDR + 0x810, 0x00170026)

/* MPDGCTRL[0-1] - read DQS gating preset values from calibration */
MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x83c, 0x04140428)
MXC_DCD_ITEM(46, MMDC_P0_BASE_ADDR + 0x840, 0x037C037C)
MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x83c, 0x0374037C)
MXC_DCD_ITEM(48, MMDC_P1_BASE_ADDR + 0x840, 0x0350032C)

/* MPRDDLCTL - read delay lines preset values from calibration */
MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x848, 0x3C30303A)
MXC_DCD_ITEM(50, MMDC_P1_BASE_ADDR + 0x848, 0x30322A3C)

/* MPWRDLCTL - write delay lines preset values from calibration */
MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x850, 0x3A344038)
MXC_DCD_ITEM(52, MMDC_P1_BASE_ADDR + 0x850, 0x48304A3E)

/* MMDC1_MPRDDQBY[0-3]DL
 * rd_dq[0-7]_del	= 0x3 (3 delay units - recommended value)
 */
MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

/* MMDC2_MPRDDQBY[0-3]DL
 * rd_dq[0-7]_del	= 0x3 (3 delay units - recommended value)
 */
MXC_DCD_ITEM(57, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(60, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

/* MPMUR0
 * MU_BYP_VAL	= 0 (irrelevant for normal use)
 * MU_BYP_EN	= 0 (irrelevant for normal use: use MU_UNIT_DEL_NUM)
 * FRC_MSR	= 1 (complete calibration by forced measurement)
 * MU_UNIT_DEL_NUM	= 0 (irrelevant for normal use)
 */
MXC_DCD_ITEM(61, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
MXC_DCD_ITEM(62, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)

/* MDPDC
 * tCKSRE	= 0x6 (6 cycles)
 * tCKSRX	= 0x6 (6 cycles)
 * BOTH_CS_PD	= 0 (independent PD)
 * SLOW_PD	= 0 (fast mode)
 * PWDT_0	= 0 (disabled)
 * PWDT_1	= 0 (disabled)
 * tCKE		= 0x2 (3 cycles)
 * PRCT_0	= 0 (disabled)
 * PRCT_1	= 0 (disabled)
 */
MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x004, 0x00020036)

/* MDOTC
 * tODT_idle_off	= 0x4 (4 cycles)
 * tODTLon		= 0x4 (4 cycles)
 * tAXPD		= 0x4 (5CK)
 * tANPD		= 0x4 (5CK)
 * tAONPD		= 0x1 (2 cycles) ?
 * tAOFPD		= 0x1 (2 cycles) ?
 */
MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)

/* MDCFG0
 * tRFC	  = 0x8A (139CK = ~260ns)
 * tXS	  = 0x8F (144CK = ~270ns)
 * tXP	  = 0x3 (4CK = ~7.5ns)
 * tXPDDL = 0xC (13CK = ~24.375ns)
 * tFAW	  = 0x1A (27CK  = ~50ns)
 * tCL	  = 0x5 (8 cycles)
 */
MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x00c, 0x8A8F79A5)

/* MDCFG1
 * tCWL	  = 0x4 (6 cycles)
 * tMRD	  = 0xB (12CK = ~22.5ns)
 * tWR	  = 0x7 (8 cycles = 15ns)
 * tRPA	  = 0x1 (tRP + 1)
 * tRAS	  = 0x13 (20CK = 37.5ns)
 * tRC	  = 0x1B (28CK = 50.625ns)
 * tRP	  = 0x7 (8CK = 15ns)
 * tRCD	  = 0x7 (8CK = 15ns)
 */
MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x010, 0xFF738F64)

/* MDCFG2
 * tRRD	  = 0x5 (6 cycles = 10ns)
 * tWTR	  = 0x3 (4 cycles = 7.5ns)
 * tRTP	  = 0x3 (4 cycles = 7.5ns)
 * tDLLK  = 0x1FF (JEDEC value for DDR3: 512 cycles = 960ns)
 */
MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DD)

/* MDMISC
 * RST		= 0 (no reset)
 * LPDDR2_2CH	= 0 (DDR3 mode)
 * DDR_TYPE	= 0 (DDR3 mode)
 * DDR_4_BANK	= 0 (8 banks)
 * RALAT	= 0x5 cycles
 * MIF3_MODE	= 0x3
 * LPDDR2_S2	= 0 (DDR3)
 * BI_ON	= 0x1 (banks interleave on)
 * WALAT	= 0x1 (1 cycles)
 * LHD		= 0 (Latency hiding on)
 * ADDR_MIRROR	= 0x1
 * CALIB_PER_CS	= 0 (Calib target CS0)
 */
MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x018, 0x00091740)

/* MDSCR */
/* Set CON_REQ - configuration request */
MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)

/* MDRWD
 * RTR_DIFF	= 0x2 (2 cycles - Default)
 * RTW_DIFF	= 0x2 (2 cycles - Default)
 * WTW_DIFF	= 0x3 (3 cycles - Default)
 * WTR_DIFF	= 0x3 (3 cycles - Default)
 * RTW_SAME	= 0x2 (2 cycles - Default)
 * tDAI		= 0 (1 cycle - irrelevant for DDR3)
 */
MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)

/* MDOR
 * RST_to_CKE	= 0x23 (33 cycles - JEDEC for DDR3 - 500us)
 * SDE_to_RST	= 0x10 (14 cycles - JEDEC for DDR3 - 200us)
 * tXPR		= 0x8F (144 cycles = tRFC + 10ns)
 */
MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x030, 0x008F1023)

/* MDCTL - configure physical DRAM parameters */
#if defined(CONFIG_DDR_16BIT)
/* DSIZ = 0 (16), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & !CS1 */
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x83180000)
#elif defined(CONFIG_DDR_32BIT_512MB)
/* DSIZ = 0x1 (32), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & !CS1 */
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x83190000)
#elif defined(CONFIG_DDR_64BIT_1GB)
/* DSIZ = 0x2 (64), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & !CS1 */
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x831A0000)
#elif defined(CONFIG_DDR_64BIT_2GB)
/* DSIZ = 0x2 (64), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x3 (14), CS0 & CS1 */
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0xC31A0000)
#elif defined(CONFIG_DDR_64BIT_4GB)
/* DSIZ = 0x2 (64), BL = 0x1 (8), COL = 0x1 (10), ROW = 0x4 (15), CS0 & CS1 */
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0xC41A0000)
#else
# error "DRAM data bus width must be defined!"
#endif /* CONFIG_DDR_16BIT */

/* MDSCR
 * CMD_BA	= 0x2 (MR2)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0x8 (CWL = 0x1, ASR = 0, SRT = 0)
 * CMD_ADDR_MSB_MR_OP	= 0 (RTT(WR) = 0 is Micron recommended value)
 */
MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x00088032)
MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x0008803A)

/* MDSCR
 * CMD_BA	= 0x3 (MR3)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0 (MPR_RF = 0, MPR = 0)
 * CMD_ADDR_MSB_MR_OP	= 0 (reserved)
 */
MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)
MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x0000803B)

/* MDSCR
 * CMD_BA	= 0x1 (MR1)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0 (DLL = 0, ODS = 0x1 (34OHM),
 *	RTT[0-1] = 0x1 (60OHM), AL = 0, WL = 0)
 * CMD_ADDR_MSB_MR_OP	= 0 (RTT[2] = 0, TDQS = 0, QOff = 0 (enabled))
 */
MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x00068031)
MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x01c, 0x00068039)

/* MDSCR
 * CMD_BA	= 0 (MR0)
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x3 (Load mode register)
 * WL_EN	= 0 (stay in normal mode)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0x40 (BL = 0, CL = 0x8 (8 cycles), BT = 0)
 * CMD_ADDR_MSB_MR_OP	= 0x9 (DLL = 1 (reset DLL), WR = 0x4 (8), PD = 0)
 */
MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)
MXC_DCD_ITEM(80, MMDC_P0_BASE_ADDR + 0x01c, 0x09408038)

/* MDSCR
 * CMD_BA	= 0 (ignored )
 * CMD_CS	= 0,1 (first command for CS0, second - CS1)
 * CMD		= 0x4 (ZQ calibration)
 * WL_EN	= 0 (ignored)
 * MRR_READ_DATA_VALID	= 0 (irrelevant for DDR3)
 * CON_ACK	= 0 (RO field)
 * CON_REQ	= 1 (we're in config mode)
 * CMD_ADDR_LSB_MR_ADDR	= 0 (must be 0)
 * CMD_ADDR_MSB_MR_OP	= 0x4 (can be 0 for ZQCS or 0x4 for ZQCL)
 */
MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)
MXC_DCD_ITEM(82, MMDC_P0_BASE_ADDR + 0x01c, 0x04008048)

/* MDREF
 * START_REF	= 0 (do not start a refresh cycle)
 * REFR		= 0x7 (8 refreshes) ?
 * REF_SEL	= 0x1 (use 32KHz)
 * REF_CNT	= 0 (not used)
 */
MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

/* MPODTCTRL
 * ODT_WR_PAS_EN	= 0x1 (Inactive CS ODT enabled during write)
 * ODT_WR_ACT_EN	= 0x1 (Active CS ODT enabled during write)
 * ODT_RD_PAS_EN	= 0x1 (Inactive CS ODT enabled during read)
 * ODT_RD_ACT_EN	= 0 (Active CS ODT disabled during read)
 * ODT0_INT_RES		= 0x2 (i.MX RTT for byte 0/4 - 60OHM)
 * ODT1_INT_RES		= 0x2 (i.MX RTT for byte 1/5 - 60OHM)
 * ODT2_INT_RES		= 0x2 (i.MX RTT for byte 2/6 - 60OHM)
 * ODT3_INT_RES		= 0x2 (i.MX RTT for byte 3/7 - 60OHM)
 */
MXC_DCD_ITEM(84, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)
MXC_DCD_ITEM(85, MMDC_P1_BASE_ADDR + 0x818, 0x00022227)

/* MDPDC
 * tCKSRE	= 0x6 (6 cycles)
 * tCKSRX	= 0x6 (6 cycles)
 * BOTH_CS_PD	= 0x1
 * SLOW_PD	= 0x1 (slow mode)
 * PWDT_0	= 0x5 (256 cycles)
 * PWDT_1	= 0x5 (256 cycles)
 * tCKE		= 0x2 (3 cycles)
 * PRCT_0	= 0 (disabled) ?
 * PRCT_1	= 0 (disabled) ?
 */
MXC_DCD_ITEM(86, MMDC_P0_BASE_ADDR + 0x004, 0x000255F6)

/* MAPSR
 * PSD		= 0 (enabled)
 * PSS		= 0 (ro)
 * RIS		= 0 (ro)
 * WIS		= 0 (ro)
 * PST		= 0x10 (1024 cycles)
 * LPMD		= 0 (do not request lpmd)
 * DVFS		= 0 (do not request dvfs)
 * LPACK	= 0 (ro)
 * DVACK	= 0 (ro)
 */
MXC_DCD_ITEM(87, MMDC_P0_BASE_ADDR + 0x404, 0x00001006)

/* MDSCR - leave configuration mode */
MXC_DCD_ITEM(88, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

#endif /* CONFIG_MX6SOLO_DDR3 */
#endif /* CONFIG_FLASH_HEADER */
