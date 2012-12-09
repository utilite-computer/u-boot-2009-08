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
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <config.h>
#include <common.h>
#include <command.h>

#ifdef __PPC__
/*
 * At least on G2 PowerPC cores, sequential accesses to non-existent
 * memory must be synchronized.
 */
# include <asm/io.h>	/* for sync() */
#else
# define sync()		/* nothing */
#endif

/*
 * Check memory range for valid RAM. A simple memory test determines
 * the actually available RAM size between addresses `base' and
 * `base + maxsize'.
 */
unsigned long get_ram_size(unsigned long *base, unsigned long maxsize)
{
	volatile unsigned long *addr;
	unsigned long           save[32];
	unsigned long           cnt;
	unsigned long           val;
	unsigned long           size;
	int            i = 0;

	for (cnt = (maxsize / sizeof (long)) >> 1; cnt > 0; cnt >>= 1) {
		addr = base + cnt;	/* pointer arith! */
		sync ();
		save[i++] = *addr;
		sync ();
		*addr = ~cnt;
	}

	addr = base;
	sync ();
	save[i] = *addr;
	sync ();
	*addr = 0;

	sync ();
	if ((val = *addr) != 0) {
		/* Restore the original data before leaving the function.
		 */
		sync ();
		*addr = save[i];
		for (cnt = 1; cnt < maxsize / sizeof(long); cnt <<= 1) {
			addr  = base + cnt;
			sync ();
			*addr = save[--i];
		}
		return (0);
	}

	for (cnt = 1; cnt < maxsize / sizeof (long); cnt <<= 1) {
		addr = base + cnt;	/* pointer arith! */
		val = *addr;
		*addr = save[--i];
		if (val != ~cnt) {
			size = cnt * sizeof (long);
			/* Restore the original data before leaving the function.
			 */
			for (cnt <<= 1; cnt < maxsize / sizeof (long); cnt <<= 1) {
				addr  = base + cnt;
				*addr = save[--i];
			}
			return (size);
		}
	}

	return (maxsize);
}

int do_check_memsize(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	u32 base, maxsize, size;

	if (argc < 3) {
		cmd_usage(cmdtp);
		return 1;
	}

	base = simple_strtoul(argv[1], NULL, 16);
	maxsize = simple_strtoul(argv[2], NULL, 16);

	size = get_ram_size((unsigned long *)base, maxsize);
	printf("Found %uMB (%u bytes) of memory\n", size >> 20, size);

	return 0;
}

U_BOOT_CMD(
	memsize,	3,	0,	do_check_memsize,
	"check the memory size",
	"<base address> <max size>"
);
