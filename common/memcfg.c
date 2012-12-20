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

static inline void print_num(const char *name, ulong value)
{
	printf ("%-12s= 0x%08lX\n", name, value);
}

static void print_dram_config(void)
{
	int i;
	for (i=0; i < CONFIG_NR_DRAM_BANKS; ++i) {
		print_num("DRAM bank",	i);
		print_num("-> start",	gd->bd->bi_dram[i].start);
		print_num("-> size",	gd->bd->bi_dram[i].size);
	}
}

int do_memcfg(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	u32 base, size;
	unsigned int bank;

	if (argc > 1 && argc < 4) {
		cmd_usage(cmdtp);
		return 1;
	}

	bank = simple_strtoul(argv[1], NULL, 16);
	if (bank >= CONFIG_NR_DRAM_BANKS) {
		cmd_usage(cmdtp);
		return 1;
	}

	if (argc == 1) {
		print_dram_config();
		return 0;
	}

	base = simple_strtoul(argv[2], NULL, 16);
	size = simple_strtoul(argv[3], NULL, 16);

	gd->bd->bi_dram[bank].start = base;
	gd->bd->bi_dram[bank].size = size;
	print_dram_config();

	return 0;
}

U_BOOT_CMD(
	memcfg,	4,	0,	do_memcfg,
	"view or change the dram setup in bd->bi_dram[bank]",
	"[<bank> <base address> <size>]"
);
