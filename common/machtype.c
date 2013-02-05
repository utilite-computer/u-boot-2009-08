/*
 * (C) Copyright 2004
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
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
 * Foundation, Inc.
 */

#include <config.h>
#include <common.h>
#include <command.h>

DECLARE_GLOBAL_DATA_PTR;

int do_machtype(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
#if 0
	if (argc > 1 && argc < 4) {
		cmd_usage(cmdtp);
		return 1;
	}
#endif

	if (argc == 2)
		gd->bd->bi_arch_number = simple_strtoul(argv[1], NULL, 16);

	printf("Machine ID:\t0x%lX\n", gd->bd->bi_arch_number);

	return 0;
}

U_BOOT_CMD(
	machtype,	2,	0,	do_machtype,
	"view or change the machine arch number in gd->bd->bi_arch_number",
	"[<new machine arch number>]"
);
