/*
 * Copyright (C) 2010-2012 Freescale Semiconductor, Inc.
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

#include <config.h>
#include <asm/arch/mx6.h>

#ifdef	CONFIG_FLASH_HEADER
#ifndef CONFIG_FLASH_HEADER_OFFSET
# error "Must define the offset of flash header"
#endif

#ifndef CONFIG_FLASH_PLUG_IN

/********************DCD mode***********************/
#define CPU_2_BE_32(l) \
       ((((l) & 0x000000FF) << 24) | \
	(((l) & 0x0000FF00) << 8)  | \
	(((l) & 0x00FF0000) >> 8)  | \
	(((l) & 0xFF000000) >> 24))

#define MXC_DCD_ITEM(i, addr, val)   \
dcd_node_##i:                        \
        .word CPU_2_BE_32(addr) ;     \
        .word CPU_2_BE_32(val)  ;     \

.section ".text.flasheader", "x"
	b	_start
	.org	CONFIG_FLASH_HEADER_OFFSET

ivt_header:       .word 0x402000D1 /* Tag=0xD1, Len=0x0020, Ver=0x40 */
app_code_jump_v:  .word _start
reserv1:          .word 0x0
dcd_ptr:          .word dcd_hdr
boot_data_ptr:	  .word boot_data
self_ptr:         .word ivt_header
#ifdef CONFIG_SECURE_BOOT
app_code_csf:     .word __hab_data
#else
app_code_csf:     .word 0x0
#endif
reserv2:          .word 0x0

boot_data:        .word TEXT_BASE
#ifdef CONFIG_SECURE_BOOT
image_len:        .word __hab_data_end - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
#else
image_len:        .word _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
#endif
plugin:           .word 0x0

#if defined CONFIG_MX6DL_DDR3
dcd_hdr:          .word 0x40E002D2 /* Tag=0xD2, Len=91*8 + 4 + 4, Ver=0x40 */
write_dcd_cmd:    .word 0x04DC02CC /* Tag=0xCC, Len=91*8 + 4, Param=0x04 */

# IOMUXC_BASE_ADDR  = 0x20e0000
# DDR IO TYPE
MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x798, 0x000c0000)
MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x758, 0x00000000)
# Clock
MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x588, 0x00000030)
MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x594, 0x00000030)
# Address
MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x56c, 0x00000030)
MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x578, 0x00000030)
MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x74c, 0x00000030)
# Control
MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x57c, 0x00000030)
MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x590, 0x00003000)
MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x598, 0x00003000)
MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x58c, 0x00000000)
MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x59c, 0x00003030)
MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x5a0, 0x00003030)
MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x78c, 0x00000030)
# Data Strobe
MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x750, 0x00020000)
MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x5a8, 0x00000030)
MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x5b0, 0x00000030)
MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x524, 0x00000030)
MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x51c, 0x00000030)
MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x518, 0x00000030)
MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x50c, 0x00000030)
MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x5b8, 0x00000030)
MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x5c0, 0x00000030)
# DATA
MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x774, 0x00020000)
MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x784, 0x00000030)
MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x788, 0x00000030)
MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x794, 0x00000030)
MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x79c, 0x00000030)
MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x7a0, 0x00000030)
MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x7a4, 0x00000030)
MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x7a8, 0x00000030)
MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x748, 0x00000030)
MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x5ac, 0x00000030)
MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x5b4, 0x00000030)
MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x528, 0x00000030)
MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x520, 0x00000030)
MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x514, 0x00000030)
MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x510, 0x00000030)
MXC_DCD_ITEM(39, IOMUXC_BASE_ADDR + 0x5bc, 0x00000030)
MXC_DCD_ITEM(40, IOMUXC_BASE_ADDR + 0x5c4, 0x00000030)

# MMDC_P0_BASE_ADDR = 0x021b0000
# MMDC_P1_BASE_ADDR = 0x021b4000
# Calibrations
# ZQ
MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x800, 0xa1390003)
MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x800, 0xa1390003)
# write leveling
MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
MXC_DCD_ITEM(45, MMDC_P1_BASE_ADDR + 0x80c, 0x00370037)
MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x810, 0x00370037)
# DQS gating, read delay, write delay calibration values
# based on calibration compare of 0x00ffff00
MXC_DCD_ITEM(47, MMDC_P0_BASE_ADDR + 0x83c, 0x422f0220)
MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x840, 0x021f0219)
MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x83C, 0x422f0220)
MXC_DCD_ITEM(50, MMDC_P1_BASE_ADDR + 0x840, 0x022d022f)
MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x848, 0x47494b49)
MXC_DCD_ITEM(52, MMDC_P1_BASE_ADDR + 0x848, 0x48484c47)
MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x850, 0x39382b2f)
MXC_DCD_ITEM(54, MMDC_P1_BASE_ADDR + 0x850, 0x2f35312c)
# read data bit delay
MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(58, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)
MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(60, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(61, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(62, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)
# Complete calibration by forced measurment
MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
MXC_DCD_ITEM(64, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)
# MMDC init:
# in DDR3, 64-bit mode, only MMDC0 is initiated:
MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x004, 0x0002002d)
MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x008, 0x00333030)

MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x00c, 0x40445323)
MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x010, 0xb66e8c63)

MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x014, 0x01ff00db)
MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x018, 0x00081740)
MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x02c, 0x000026d2)
MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x030, 0x00440e21)
MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x040, 0x0000003f)
#ifdef CONFIG_DDR_16BIT
MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x000, 0x83180000)
#elif defined(CONFIG_DDR_32BIT)
MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x000, 0xc3190000)
#elif defined(CONFIG_DDR_64BIT_4GB)
MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x000, 0xc41a0000)
#else /* 64bit <4GB */
MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x000, 0xc31a0000)
#endif /* CONFIG_DDR_16BIT */

# Initialize 2GB DDR3 - Micron MT41J128M
# MR2
MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x04008032)
MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x0400803a)
# MR3
MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)
MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x01c, 0x0000803b)
# MR1
MXC_DCD_ITEM(80, MMDC_P0_BASE_ADDR + 0x01c, 0x00428031)
MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x01c, 0x00428039)
# MR0
MXC_DCD_ITEM(82, MMDC_P0_BASE_ADDR + 0x01c, 0x07208030)
MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x01c, 0x07208038)
# ZQ calibration
MXC_DCD_ITEM(84, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)
MXC_DCD_ITEM(85, MMDC_P0_BASE_ADDR + 0x01c, 0x04008048)
# final DDR setup
MXC_DCD_ITEM(86, MMDC_P0_BASE_ADDR + 0x020, 0x00005800)
MXC_DCD_ITEM(87, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)
MXC_DCD_ITEM(88, MMDC_P1_BASE_ADDR + 0x818, 0x00022227)
MXC_DCD_ITEM(89, MMDC_P0_BASE_ADDR + 0x004, 0x0002556d)
MXC_DCD_ITEM(90, MMDC_P1_BASE_ADDR + 0x004, 0x00011006)
MXC_DCD_ITEM(91, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

#else

dcd_hdr:          .word 0x40D802D2 /* Tag=0xD2, Len=90*8 + 4 + 4, Ver=0x40 */
write_dcd_cmd:    .word 0x04D402CC /* Tag=0xCC, Len=90*8 + 4, Param=0x04 */

/* DCD */

MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x5a8, 0x00000030)
MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x5b0, 0x00000030)
MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x524, 0x00000030)
MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x51c, 0x00000030)

MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x518, 0x00000030)
MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x50c, 0x00000030)
MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x5b8, 0x00000030)
MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x5c0, 0x00000030)

MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x5ac, 0x00020030)
MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x5b4, 0x00020030)
MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x528, 0x00020030)
MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x520, 0x00020030)

MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x514, 0x00020030)
MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x510, 0x00020030)
MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x5bc, 0x00020030)
MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x5c4, 0x00020030)

MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x56c, 0x00020030)
MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x578, 0x00020030)
MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x588, 0x00020030)
MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x594, 0x00020030)

MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x57c, 0x00020030)
MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x590, 0x00003000)
MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x598, 0x00003000)
MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x58c, 0x00000000)

MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x59c, 0x00003030)
MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x5a0, 0x00003030)
MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x784, 0x00000030)
MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x788, 0x00000030)

MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x794, 0x00000030)
MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x79c, 0x00000030)
MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x7a0, 0x00000030)
MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x7a4, 0x00000030)

MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x7a8, 0x00000030)
MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x748, 0x00000030)
MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x74c, 0x00000030)
MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x750, 0x00020000)

MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x758, 0x00000000)
MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x774, 0x00020000)
MXC_DCD_ITEM(39, IOMUXC_BASE_ADDR + 0x78c, 0x00000030)
MXC_DCD_ITEM(40, IOMUXC_BASE_ADDR + 0x798, 0x000C0000)

MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

MXC_DCD_ITEM(45, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
MXC_DCD_ITEM(48, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x018, 0x00081740)

MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x00c, 0x555A7975)
MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x010, 0xFF538E64)
MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)
MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)

MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x030, 0x005B0E21)
MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)
MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x004, 0x00025576)
MXC_DCD_ITEM(58, MMDC_P0_BASE_ADDR + 0x040, 0x0000003f)

#ifdef CONFIG_DDR_16BIT
MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x000, 0x83180000)
#elif defined(CONFIG_DDR_32BIT)
MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x000, 0xc3190000)
#elif defined(CONFIG_DDR_64BIT_4GB)
MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x000, 0xc41a0000)
#else /* 64bit <4GB */
MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x000, 0xc31a0000)
#endif /* CONFIG_DDR_16BIT */

MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x01c, 0x04088032)
MXC_DCD_ITEM(61, MMDC_P0_BASE_ADDR + 0x01c, 0x0408803A)
MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)
MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x01c, 0x0000803B)
MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x01c, 0x00428031)
MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x01c, 0x00428039)
MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)
MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x01c, 0x09408038)

MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)
MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x01c, 0x04008048)
MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x800, 0xA1380003)
MXC_DCD_ITEM(71, MMDC_P1_BASE_ADDR + 0x800, 0xA1380003)
MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x020, 0x00005800)
MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)
MXC_DCD_ITEM(74, MMDC_P1_BASE_ADDR + 0x818, 0x00022227)

MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x83c, 0x434B0350)
MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x840, 0x034C0359)
MXC_DCD_ITEM(77, MMDC_P1_BASE_ADDR + 0x83c, 0x434B0350)
MXC_DCD_ITEM(78, MMDC_P1_BASE_ADDR + 0x840, 0x03650348)
MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x848, 0x4436383B)
MXC_DCD_ITEM(80, MMDC_P1_BASE_ADDR + 0x848, 0x39393341)
MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x850, 0x35373933)
MXC_DCD_ITEM(82, MMDC_P1_BASE_ADDR + 0x850, 0x48254A36)

MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
MXC_DCD_ITEM(84, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

MXC_DCD_ITEM(85, MMDC_P1_BASE_ADDR + 0x80c, 0x00440044)
MXC_DCD_ITEM(86, MMDC_P1_BASE_ADDR + 0x810, 0x00440044)

MXC_DCD_ITEM(87, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
MXC_DCD_ITEM(88, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)

MXC_DCD_ITEM(89, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)
MXC_DCD_ITEM(90, MMDC_P0_BASE_ADDR + 0x404, 0x00011006)

#endif

#else

/*****************PLUGIN IN mode********************/

#ifdef CONFIG_MX6DL_LPDDR2
.section ".text.flasheader", "x"
origin:
	b	_start
	.org	CONFIG_FLASH_HEADER_OFFSET

/* First IVT to copy the plugin that initializes the system into OCRAM */
ivt_header:             .long 0x402000D1    /*Tag=0xD1, Len=0x0020, Ver=0x40 */
app_code_jump_v:        .long IRAM_FREE_START + (plugin_start - origin)    /* Plugin entry point, address after the second IVT table */
reserv1:                .long 0x0
dcd_ptr:                .long 0x0
boot_data_ptr:          .long IRAM_FREE_START + (boot_data - origin) /*0x00907420*/
self_ptr:               .long IRAM_FREE_START + (ivt_header - origin)
app_code_csf:           .long 0x0
reserv2:                .long 0x0

boot_data:              .long IRAM_FREE_START
image_len:              .long 16*1024  /* plugin can be upto 16KB in size */
plugin:                 .long 0x1  /* Enable plugin flag */

/* Second IVT to give entry point into the bootloader copied to DDR */
ivt2_header:            .long 0x402000D1    /*Tag=0xD1, Len=0x0020, Ver=0x40 */
app2_code_jump_v:       .long _start       /* Entry point for uboot */
reserv3:                .long 0x0
dcd2_ptr:               .long 0x0
boot_data2_ptr:         .long boot_data2
self_ptr2:              .long ivt2_header
app_code_csf2:          .long 0x0
reserv4:                .long 0x0

boot_data2:             .long TEXT_BASE
image_len2:             .long _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
plugin2:                .long 0x0

/* Here starts the plugin code */
plugin_start:
/* Save the return address and the function arguments */
    push    {r0-r4, lr}

/*
 * The following is following MX6DL LPDDR2 init script
 * "MX6DL_init_LPDDR2_400MHz_1.0.inc"
 * With the change of Switch PL301_FAST2 to DDR Dual-channel
 * mapping on
 */
/*========================================================================*/
/*init script for i.MX6DL LPDDR2*/
/*========================================================================*/
/* Revision History*/
/* v1.00 : Init version for Micron MT42L64M64D2KH-18 on CPU LPDDR2 board.
   It's currently soldered, not PoPed.*/
/* Seen passing with overclocking DDR stress test up to 475MHz.*/
/* If someone is playing this init on different DDR device, or on PoPed
   board, please feedback me with result.*/
/* boaz.perlman@freescale.com*/
/*========================================================================*/

/* CCM_BASE_ADDR = 0x020C4000 */
/*DDR clk to 400MHz*/
    ldr r0, =CCM_BASE_ADDR

    ldr r1, =0x00060324
    str r1, [r0, #0x018]


/*IPU2_IPU_CLOCK and IPU1_IPU_CLOCK is necessary for setting
  the Dual-Channel Mode*/
    ldr r1, =0xFFFFFFC3
    str r1, [r0, #0x074]

/* GPV0_BASE_ADDR = 0x00B00000*/
/* Switch PL301_FAST2 to DDR Dual-channel mapping*/
/* Setting This bit to 0x1 will Cause 0x80000000 mapping to Channel 0 and
 * 0x10000000 mapping to Channel 1, setting it to 0x0 will only map
 * Channel 0 to 0x10000000*/
    ldr r0, =GPV0_BASE_ADDR
    ldr r1, =0x00000001
    str r1, [r0, #0x000]

/*========================================================================*/
/* IOMUX*/
/*========================================================================*/
/* IOMUXC_BASE_ADDR = 0x020E0000*/

/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS0*/
    ldr r0, =IOMUXC_BASE_ADDR
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4bc]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS1*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4c0]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS2*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4c4]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS3*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4c8]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS4*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4cc]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS5*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4d0]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS6*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4d4]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS7*/
    ldr r1, =0x00003030
    ldr r1, [r0, #0x4d8]

/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM0*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x470]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM1*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x474]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM2*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x478]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM3*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x47c]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM4*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x480]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM5*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x484]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM6*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x488]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM7*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x48c]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_CAS*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x464]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_RAS*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x490]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCLK_0*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x4ac]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCLK_1*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x4b0]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_RESET*/
    ldr r1, =0x00080038
    ldr r1, [r0, #0x494]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE0*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x4a4]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE1*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x4a8]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA2 - DSE can be configured using Group Control
   Register: IOMUXC_SW_PAD_CTL_GRP_CTLDS*/
    ldr r1, =0x00000000
    ldr r1, [r0, #0x4a0]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDODT0*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x4b4]
/* IOMUXC_SW_PAD_CTL_PAD_DRAM_SDODT1*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x4b8]
/* IOMUXC_SW_PAD_CTL_GRP_B0DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x764]
/* IOMUXC_SW_PAD_CTL_GRP_B1DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x770]
/* IOMUXC_SW_PAD_CTL_GRP_B2DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x778]
/* IOMUXC_SW_PAD_CTL_GRP_B3DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x77c]
/* IOMUXC_SW_PAD_CTL_GRP_B4DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x780]
/* IOMUXC_SW_PAD_CTL_GRP_B5DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x784]
/* IOMUXC_SW_PAD_CTL_GRP_B6DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x78c]
/* IOMUXC_SW_PAD_CTL_GRP_B7DS*/
    ldr r1, =0x00000030
    ldr r1, [r0, #0x748]
/* IOMUXC_SW_PAD_CTL_GRP_ADDDS*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x74c]
/* IOMUXC_SW_PAD_CTL_GRP_CTLDS*/
    ldr r1, =0x00000038
    ldr r1, [r0, #0x76c]
/* IOMUXC_SW_PAD_CTL_GRP_DDRMODE_CTL*/
    ldr r1, =0x00020000
    ldr r1, [r0, #0x750]
/* IOMUXC_SW_PAD_CTL_GRP_DDRPKE*/
    ldr r1, =0x00000000
    ldr r1, [r0, #0x754]
/* IOMUXC_SW_PAD_CTL_GRP_DDRMODE*/
    ldr r1, =0x00020000
    ldr r1, [r0, #0x760]
/* IOMUXC_SW_PAD_CTL_GRP_DDR_TYPE*/
    ldr r1, =0x00080000
    ldr r1, [r0, #0x774]

/*========================================================================*/
/* DDR Controller Registers*/
/*========================================================================*/
/* Manufacturer:	Mocron*/
/* Device Part Number:	MT42L64M64D2KH-18*/
/* Clock Freq.: 	528MHz*/
/* MMDC channels: Both MMDC0, MMDC1*/
/*Density per CS in Gb: 	256M*/
/* Chip Selects used:	2*/
/* Number of Banks:	8*/
/* Row address:    	14*/
/* Column address: 	9*/
/* Data bus width	32*/
/*========================================================================*/
/* MMDC_P0_BASE_ADDR = 0x021b0000 */
/* MMDC_P1_BASE_ADDR = 0x021b4000 */
/* MMDC0_MDSCR, set the Configuration request bit during MMDC set up*/
    ldr r0, =MMDC_P0_BASE_ADDR
    ldr r1, =MMDC_P1_BASE_ADDR
    ldr r2, =0x00008000
    str r2, [r0, #0x01c]
/* MMDC1_MDSCR, set the Configuration request bit during MMDC set up*/
    ldr r2, =0x00008000
    str r2, [r1, #0x01c]

/*LPDDR2 ZQ params*/
    ldr r2, =0x1b5f01ff
    str r2, [r0, #0x85c]
    ldr r2, =0x1b5f01ff
    str r2, [r1, #0x85c]

/*========================================================================*/
/* Calibration setup.*/
/*========================================================================*/
/* DDR_PHY_P0_MPZQHWCTRL, enable on time ZQ calibration*/
    ldr r2, =0xa1390003
    str r2, [r0, #0x800]

/*ca bus abs delay*/
    ldr r2, =0x00400000
    str r2, [r0, #0x890]
/*ca bus abs delay*/
    ldr r2, =0x00400000
    str r2, [r1, #0x890]
/* values of 20,40,50,60,7f tried. no difference seen*/

/*frc_msr.*/
    ldr r2, =0x00000800
    str r2, [r0, #0x8b8]
/*frc_msr.*/
    ldr r2, =0x00000800
    str r2, [r1, #0x8b8]

/* DDR_PHY_P0_MPREDQBY0DL3*/
    ldr r2, =0x33333333
    str r2, [r0, #0x81c]
/* DDR_PHY_P0_MPREDQBY1DL3*/
    ldr r2, =0x33333333
    str r2, [r0, #0x820]
/* DDR_PHY_P0_MPREDQBY2DL3*/
    ldr r2, =0x33333333
    str r2, [r0, #0x824]
/* DDR_PHY_P0_MPREDQBY3DL3*/
    ldr r2, =0x33333333
    str r2, [r0, #0x828]

/* DDR_PHY_P1_MPREDQBY0DL3*/
    ldr r2, =0x33333333
    str r2, [r1, #0x81c]
/* DDR_PHY_P1_MPREDQBY1DL3*/
    ldr r2, =0x33333333
    str r2, [r1, #0x820]
/* DDR_PHY_P1_MPREDQBY2DL3*/
    ldr r2, =0x33333333
    str r2, [r1, #0x824]
/* DDR_PHY_P1_MPREDQBY3DL3*/
    ldr r2, =0x33333333
    str r2, [r1, #0x828]

/*write delayes:*/
/*setmem /32 0x021b082c = 0xf3333333 all byte 0 data & dm delayed by 3*/
/*all byte 1 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r0, #0x830]
/*all byte 2 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r0, #0x834]
/*all byte 3 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r0, #0x838]


/*all byte 0 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r1, #0x82c]
/*all byte 1 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r1, #0x830]
/*all byte 2 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r1, #0x834]
/*all byte 3 data & dm delayed by 3*/
    ldr r2, =0xf3333333
    str r2, [r1, #0x838]

/* Read and write data delay, per byte.*/
/* For optimized DDR operation it is recommended to run mmdc_calibration on
   your board, and replace 4 delay register assigns with resulted values*/
/* Note:*/
/* a. DQS gating is not relevant for LPDDR2. DSQ gating calibration section
   should be skipped, or the write/read calibration comming after that
   will stall*/
/* b. The calibration code that runs for both MMDC0 & MMDC1 should be used.*/

/*it is strongly recommended to run calibration on your board, and replace
  bellow values:*/

/*Read calibration*/
    ldr r2, =0x444A4F4D
    str r2, [r0, #0x848]
    ldr r2, =0x4B4E4042
    str r2, [r1, #0x848]

/*Write calibration*/
    ldr r2, =0x312E272E
    str r2, [r0, #0x850]
    ldr r2, =0x28302E2B
    str r2, [r1, #0x850]

/*dqs gating dis*/
    ldr r2, =0x20000000
    str r2, [r0, #0x83c]
    ldr r2, =0x0
    str r2, [r0, #0x840]
    ldr r2, =0x20000000
    str r2, [r1, #0x83c]
    ldr r2, =0x0
    str r2, [r1, #0x840]


/*setmem /32 0x021b0858 = 0xa00 clk delay*/
/*setmem /32 0x021b4858 = 0xa00 clk delay*/

/*frc_msr*/
    ldr r2, =0x00000800
    str r2, [r0, #0x8b8]
/*frc_msr*/
    ldr r2, =0x00000800
    str r2, [r1, #0x8b8]

/*========================================================================*/
/* Calibration setup end*/
/*========================================================================*/
/* Channel0 - startng address 0x80000000*/
/* MMDC0_MDCFG0*/
    ldr r2, =0x3f436133
    str r2, [r0, #0x00c]
/* MMDC0_MDPDC*/
    ldr r2, =0x00020024
    str r2, [r0, #0x004]
/* MMDC0_MDCFG1*/
    ldr r2, =0x00100A82
    str r2, [r0, #0x010]
/* MMDC0_MDCFG2*/
    ldr r2, =0x00000093
    str r2, [r0, #0x014]

/* MMDC0_MDMISC*/
    ldr r2, =0x0000174C
    str r2, [r0, #0x018]
/* MMDC0_MDRWD;*/
    ldr r2, =0x0f9f26d2
    str r2, [r0, #0x02c]
/* MMDC0_MDOR*/
    ldr r2, =0x0000020e
    str r2, [r0, #0x030]

/* MMDC0_MDCFG3LP*/
    ldr r2, =0x001a099a
    str r2, [r0, #0x038]

/* MMDC0_MDOTC*/
    ldr r2, =0x00000000
    str r2, [r0, #0x008]

/* CS0_END*/
    ldr r2, =0x0000005f
    str r2, [r0, #0x040]

/* ROC*/
    ldr r2, =0x0000000f
    str r2, [r0, #0x404]

/* MMDC0_MDCTL*/
    ldr r2, =0xc3010000
    str r2, [r0, #0x000]

/* Channel1 - starting address 0x10000000*/
/* MMDC1_MDCFG0*/
    ldr r2, =0x3f436133
    str r2, [r1, #0x00c]

/* MMDC1_MDPDC*/
    ldr r2, =0x00020024
    str r2, [r1, #0x004]
/* MMDC1_MDCFG1*/
    ldr r2, =0x00100A82
    str r2, [r1, #0x010]
/* MMDC1_MDCFG2*/
    ldr r2, =0x00000093
    str r2, [r1, #0x014]
/* MMDC1_MDMISC*/
    ldr r2, =0x0000174C
    str r2, [r1, #0x018]
/* MMDC1_MDRWD;*/
    ldr r2, =0x0f9f26d2
    str r2, [r1, #0x02c]
/* MMDC1_MDOR*/
    ldr r2, =0x0000020e
    str r2, [r1, #0x030]
/* MMDC1_MDCFG3LP*/
    ldr r2, =0x001a099a
    str r2, [r1, #0x038]
/* MMDC1_MDOTC*/
    ldr r2, =0x00000000
    str r2, [r1, #0x008]

/* CS0_END*/
    ldr r2, =0x0000003f
    str r2, [r1, #0x040]

/* MMDC1_MDCTL*/
    ldr r2, =0xc3010000
    str r2, [r1, #0x000]

/* Channel0 : Configure DDR device:*/
/* MRW: BA=0 CS=0 MR_ADDR=63 MR_OP=0*/
    ldr r2, =0x003f8030
    str r2, [r0, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=10 MR_OP=ff*/
    ldr r2, =0xff0a8030
    str r2, [r0, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=1  MR_OP=c2*/
    ldr r2, =0xc2018030
    str r2, [r0, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=2  MR_OP=4. tcl=6, tcwl=3*/
    ldr r2, =0x04028030
    str r2, [r0, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=3  MR_OP=2.drive=240/6*/
    ldr r2, =0x02038030
    str r2, [r0, #0x01c]

/* Channel1 : Configure DDR device:*/
/* MRW: BA=0 CS=0 MR_ADDR=63 MR_OP=0*/
    ldr r2, =0x003f8030
    str r2, [r1, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=10 MR_OP=ff*/
    ldr r2, =0xff0a8030
    str r2, [r1, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=1  MR_OP=c2*/
    ldr r2, =0xc2018030
    str r2, [r1, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=2  MR_OP=4. tcl=6, tcwl=3*/
    ldr r2, =0x04028030
    str r2, [r1, #0x01c]
/* MRW: BA=0 CS=0 MR_ADDR=3  MR_OP=2.drive=240/6*/
    ldr r2, =0x02038030
    str r2, [r1, #0x01c]

/* MMDC0_MDREF*/
    ldr r2, =0x00005800
    str r2, [r0, #0x020]
/* MMDC1_MDREF*/
    ldr r2, =0x00005800
    str r2, [r1, #0x020]

/* DDR_PHY_P0_MPODTCTRL*/
    ldr r2, =0x00000000
    str r2, [r0, #0x818]
/* DDR_PHY_P1_MPODTCTRL*/
    ldr r2, =0x00000000
    str r2, [r1, #0x818]


/*######################################################*/
/*calibration values based on calibration compare of 0x00ffff00:*/
/*Note, these calibration values are based on Freescale's board*/
/*May need to run calibration on target board to fine tune these*/
/*######################################################*/

/* DDR_PHY_P0_MPZQHWCTRL, enable automatic ZQ calibration*/
    ldr r2, =0xa1310003
    str r2, [r0, #0x800]

/* DDR_PHY_P0_MPMUR0, frc_msr*/
    ldr r2, =0x00000800
    str r2, [r0, #0x8b8]
/* DDR_PHY_P1_MPMUR0, frc_msr*/
    ldr r2, =0x00000800
    str r2, [r1, #0x8b8]

/* MMDC0_MDSCR, clear this register (especially the configuration
   bit as initialization is complete)*/
    ldr r2, =0x00000000
    str r2, [r0, #0x01c]
/* MMDC0_MDSCR, clear this register (especially the configuration
   bit as initialization is complete)*/
    ldr r2, =0x00000000
    str r2, [r1, #0x01c]

/* DDR_PHY_P0_MPMUR0, frc_msr*/
    ldr r2, =0x00000800
    str r2, [r0, #0x8b8]
/* DDR_PHY_P1_MPMUR0, frc_msr*/
    ldr r2, =0x00000800
    str r2, [r1, #0x8b8]

/*
 * End of LPDDR init script
 */

/*
    The following is to fill in those arguments for this ROM function
    pu_irom_hwcnfg_setup(void **start, size_t *bytes, const void *boot_data)

    This function is used to copy data from the storage media into DDR.

    start - Initial (possibly partial) image load address on entry.  Final
    image load address on exit.
    bytes - Initial (possibly partial) image size on entry.  Final image size
    on exit.
    boot_data - Initial @ref ivt Boot Data load address.
*/
    adr r0, DDR_DEST_ADDR
    adr r1, COPY_SIZE
    adr r2, BOOT_DATA

/*
 * check the _pu_irom_api_table for the address
 * pu_irom_hwcnfg_setup is in 0x1fb5  ERIC : < what is the address in Rigel >
 */
before_calling_rom___pu_irom_hwcnfg_setup:
    mov r4, #0x1f00
    add r4, r4, #0xb5
    blx r4	/* This address might change in future ROM versions */
after_calling_rom___pu_irom_hwcnfg_setup:

/* To return to ROM from plugin, we need to fill in these argument.
 * Here is what need to do:
 * Need to construct the paramters for this function before return to ROM:
 * plugin_download(void **start, size_t *bytes, UINT32 *ivt_offset)
 */
    pop {r0-r4, lr}
    ldr r5, DDR_DEST_ADDR
    str r5, [r0]
    ldr r5, COPY_SIZE
    str r5, [r1]
    mov r5, #0x400  /* Point to the second IVT table at offset 0x42C */
    add r5, r5, #0x2C
    str r5, [r2]
    mov r0, #1

    bx lr          /* return back to ROM code */

DDR_DEST_ADDR:    .word   TEXT_BASE
COPY_SIZE:        .word   _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
BOOT_DATA:        .word   TEXT_BASE
                  .word   _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
                  .word   0
#else

/*DDR clock:480MHz, ipg clock:40MHz, AHB clock:80MHz*/
#define CONFIG_IPG_40M_FR_PLL3

.section ".text.flasheader", "x"
	b	_start
	.org	CONFIG_FLASH_HEADER_OFFSET

/* First IVT to copy the plugin that initializes the system into OCRAM */
ivt_header:             .long 0x402000D1    /*Tag=0xD1, Len=0x0020, Ver=0x40 */
app_code_jump_v:        .long 0x00907458    /* Plugin entry point, address after the second IVT table */
reserv1:                .long 0x0
dcd_ptr:                .long 0x0
boot_data_ptr:          .long 0x00907420
self_ptr:               .long 0x00907400
app_code_csf:           .long 0x0
reserv2:                .long 0x0
boot_data:              .long 0x00907000
image_len:              .long 16*1024  /* plugin can be upto 16KB in size */
plugin:                 .long 0x1  /* Enable plugin flag */

/* Second IVT to give entry point into the bootloader copied to DDR */
ivt2_header:            .long 0x402000D1    /*Tag=0xD1, Len=0x0020, Ver=0x40 */
app2_code_jump_v:       .long _start       /* Entry point for uboot */
reserv3:                .long 0x0
dcd2_ptr:               .long 0x0
boot_data2_ptr:         .long boot_data2
self_ptr2:              .long ivt2_header
app_code_csf2:          .long 0x0
reserv4:                .long 0x0
boot_data2:             .long TEXT_BASE
image_len2:             .long _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
plugin2:                .long 0x0

/* Here starts the plugin code */
plugin_start:
/* Save the return address and the function arguments */
    push    {r0-r4, lr}

/*
 * Note: The DDR settings provided below are specific to Freescale development boards and are the latest settings at the time of release.
 * However, it is recommended to contact your Freescale representative in case there are any improvements to these settings.
 */
#ifdef CONFIG_IPG_40M_FR_PLL3
    /*select pll3 for ipg clk 40M */
    ldr r0, =CCM_BASE_ADDR
    ldr r1, [r0,#0x14]
    ldr r2, =0x2000000
    orr r1, r1, r2
    ldr r2, =0x1c00
    bic r1, r2
    ldr r2, =0x1400
    orr r1, r1, r2
    str r1, [r0,#0x14]

    /*enable pll3 */
    ldr r0, =ANATOP_BASE_ADDR
    ldr r1, =0x10000
    str r1, [r0,#0x28]
    ldr r1, =0x3040
    str r1, [r0,#0x24]
#endif

    /* Init the DDR according the init script */
    ldr r0, =CCM_BASE_ADDR
    /* select 528MHz for pre_periph_clk_sel */
    ldr r1, =0x00020324
    str r1, [r0,#0x18]

    /* IOMUX setting */
    ldr r0, =IOMUXC_BASE_ADDR
    mov r1, #0x30
    str r1, [r0,#0x5a8]
    str r1, [r0,#0x5b0]
    str r1, [r0,#0x524]
    str r1, [r0,#0x51c]
    str r1, [r0,#0x518]
    str r1, [r0,#0x50c]
    str r1, [r0,#0x5b8]
    str r1, [r0,#0x5c0]

    ldr r1, =0x00020030
    str r1, [r0,#0x5ac]
    str r1, [r0,#0x5b4]
    str r1, [r0,#0x528]
    str r1, [r0,#0x520]
    str r1, [r0,#0x514]
    str r1, [r0,#0x510]
    str r1, [r0,#0x5bc]
    str r1, [r0,#0x5c4]

    str r1, [r0,#0x56c]
    str r1, [r0,#0x578]
    str r1, [r0,#0x588]
    str r1, [r0,#0x594]
    str r1, [r0,#0x57c]

    ldr r1, =0x00003000
    str r1, [r0,#0x590]
    str r1, [r0,#0x598]
    mov r1, #0x00000000
    str r1, [r0,#0x58c]
    ldr r1, =0x00003030
    str r1, [r0,#0x59c]
    str r1, [r0,#0x5a0]

    ldr r1, =0x00000030
    str r1, [r0,#0x784]
    str r1, [r0,#0x788]
    str r1, [r0,#0x794]
    str r1, [r0,#0x79c]
    str r1, [r0,#0x7a0]
    str r1, [r0,#0x7a4]
    str r1, [r0,#0x7a8]
    str r1, [r0,#0x748]
    str r1, [r0,#0x74c]

    mov r1, #0x00020000
    str r1, [r0,#0x750]

    mov r1, #0x00000000
    str r1, [r0,#0x758]

    mov r1, #0x00020000
    str r1, [r0,#0x774]
    mov r1, #0x30
    str r1, [r0,#0x78c]
    mov r1, #0x000c0000
    str r1, [r0,#0x798]

    /* Initialize 2GB DDR3 - Micron MT41J128M */
    ldr r0, =MMDC_P0_BASE_ADDR
    ldr r2, =MMDC_P1_BASE_ADDR

    ldr r1, =0x33333333
    str r1, [r0,#0x81c]
    str r1, [r0,#0x820]
    str r1, [r0,#0x824]
    str r1, [r0,#0x828]
    str r1, [r2,#0x81c]
    str r1, [r2,#0x820]
    str r1, [r2,#0x824]
    str r1, [r2,#0x828]

    ldr r1, =0x00081740
    str r1, [r0,#0x18]
    ldr r1, =0x00008000
    str r1, [r0,#0x1c]
    ldr r1, =0x555a7975
    str r1, [r0,#0x0c]
    ldr r1, =0xff538e64
    str r1, [r0,#0x10]
    ldr r1, =0x01ff00db
    str r1, [r0,#0x14]

    ldr r1, =0x000026d2
    str r1, [r0,#0x2c]
    ldr r1, =0x005b0e21
    str r1, [r0,#0x30]
    ldr r1, =0x94444040
    str r1, [r0,#0x08]
    ldr r1, =0x00020036
    str r1, [r0,#0x04]
    ldr r1, =0x00000027
    str r1, [r0,#0x40]
    ldr r1, =0xc31a0000
    str r1, [r0,#0x00]

    ldr r1, =0x04088032
    str r1, [r0,#0x1c]
    ldr r1, =0x0408803a
    str r1, [r0,#0x1c]
    ldr r1, =0x00008033
    str r1, [r0,#0x1c]
    ldr r1, =0x0000803b
    str r1, [r0,#0x1c]
    ldr r1, =0x00428031
    str r1, [r0,#0x1c]
    ldr r1, =0x00428039
    str r1, [r0,#0x1c]

    ldr r1, =0x09408030
    str r1, [r0,#0x1c]
    ldr r1, =0x09408038
    str r1, [r0,#0x1c]
    ldr r1, =0x04008040
    str r1, [r0,#0x1c]
    ldr r1, =0x04008048
    str r1, [r0,#0x1c]

    ldr r1, =0xa5380003
    str r1, [r0,#0x800]
    ldr r1, =0xa5380003
    str r1, [r2,#0x800]

    ldr r1, =0x00005800
    str r1, [r0,#0x20]

    ldr r1, =0x00022227
    str r1, [r0,#0x818]
    ldr r1, =0x00022227
    str r1, [r2,#0x818]

    ldr r1, =0x433f033f
    str r1, [r0,#0x83c]

    ldr r1, =0x033f033f
    str r1, [r0,#0x840]

    ldr r1, =0x433f033f
    str r1, [r2,#0x83c]

    ldr r1, =0x0344033b
    str r1, [r2,#0x840]

    ldr r1, =0x4337373e
    str r1, [r0,#0x848]
    ldr r1, =0x3634303d
    str r1, [r2,#0x848]

    ldr r1, =0x35374640
    str r1, [r0,#0x850]
    ldr r1, =0x4a294b35
    str r1, [r2,#0x850]

    ldr r1, =0x001F001F
    str r1, [r0,#0x80c]
    ldr r1, =0x001F001F
    str r1, [r0,#0x810]

    ldr r1, =0x00440044
    str r1, [r2,#0x80c]
    ldr r1, =0x00440044
    str r1, [r2,#0x810]

    ldr r1, =0x00000800
    str r1, [r0,#0x8b8]
    ldr r1, =0x00000800
    str r1, [r2,#0x8b8]

    ldr r1, =0x00000000
    str r1, [r0,#0x1c]


/*
    The following is to fill in those arguments for this ROM function
    pu_irom_hwcnfg_setup(void **start, size_t *bytes, const void *boot_data)

    This function is used to copy data from the storage media into DDR.

    start - Initial (possibly partial) image load address on entry.  Final image load address on exit.
    bytes - Initial (possibly partial) image size on entry.  Final image size on exit.
    boot_data - Initial @ref ivt Boot Data load address.
*/

    adr r0, DDR_DEST_ADDR
    adr r1, COPY_SIZE
    adr r2, BOOT_DATA

/*
 * check the _pu_irom_api_table for the address
 */
before_calling_rom___pu_irom_hwcnfg_setup:
    mov r4, #0x2000
    add r4, r4, #0xed
    blx r4	/* This address might change in future ROM versions */
after_calling_rom___pu_irom_hwcnfg_setup:

/* To return to ROM from plugin, we need to fill in these argument.
 * Here is what need to do:
 * Need to construct the paramters for this function before return to ROM:
 * plugin_download(void **start, size_t *bytes, UINT32 *ivt_offset)
 */
    pop {r0-r4, lr}
    ldr r5, DDR_DEST_ADDR
    str r5, [r0]
    ldr r5, COPY_SIZE
    str r5, [r1]
    mov r5, #0x400  /* Point to the second IVT table at offset 0x42C */
    add r5, r5, #0x2C
    str r5, [r2]
    mov r0, #1

    bx lr          /* return back to ROM code */

DDR_DEST_ADDR:    .word   TEXT_BASE
COPY_SIZE:        .word   _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
BOOT_DATA:        .word   TEXT_BASE
                  .word   _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
                  .word   0
/*********************************************************************/
#endif
#endif

#endif