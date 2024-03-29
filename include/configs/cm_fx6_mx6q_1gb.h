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

#define CONFIG_MX6Q
#define CONFIG_DDR_64BIT_1GB
#define CONFIG_NR_DRAM_BANKS	1
#define PHYS_SDRAM_1_SIZE	(1 << 30)	/* 1GB */

#define CONFIG_CMD_SATA

#include "cm_fx6.h"
