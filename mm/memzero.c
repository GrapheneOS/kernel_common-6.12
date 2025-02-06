// SPDX-License-Identifier: GPL-2.0
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/init.h>
#include <linux/memblock.h>
#include <linux/string.h>

void __init early_memzero(phys_addr_t start, phys_addr_t end)
{
	u64 i;
	phys_addr_t this_start, this_end;

	pr_info("Early memory zeroing");
	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &this_start,
				&this_end, NULL) {
		this_start = clamp(this_start, start, end);
		this_end = clamp(this_end, start, end);
		if (this_start < this_end) {
			pr_info("  zero %pa - %pa\n", &this_start, &this_end);
			memzero_explicit(__va(this_start), this_end - this_start);
		}
	}
}
