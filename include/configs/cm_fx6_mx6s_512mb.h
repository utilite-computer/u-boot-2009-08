/*
 * Copyright (C) 2013 CompuLab, Ltd.
 * Author: Igor Grinberg <grinberg@compulab.co.il>
 *
 * Configuration settings for the CompuLab CM-FX6 board.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc.
 */

#define CONFIG_MX6DL				/* DL/S */
#define CONFIG_MX6DL_DDR3			/* DL/S */
#define CONFIG_DDR_32BIT			/* Solo uses only 32bit */
#define CONFIG_NR_DRAM_BANKS	1
#define PHYS_SDRAM_1_SIZE	(512 << 20)	/* 512MB */

#include "cm_fx6.h"
