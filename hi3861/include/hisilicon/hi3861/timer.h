/*
 * Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <stdint.h>

typedef struct {
	/* 0x000 */ volatile uint32_t LOADCOUNT;
	/* 0x004 */ volatile uint32_t CURRENTVALUE;
	/* 0x008 */ volatile union {
		uint32_t val;
		struct {
			uint32_t en: 1;
			uint32_t mode: 1;
			uint32_t int_mask: 1;
			uint32_t lock: 1;
			uint32_t __reserved: 28;
		} bit;
	} CONTROLREG;
	/* 0x00C */ volatile uint32_t EOI;
	/* 0x010 */ volatile uint32_t INTSTATUS;
} HI3861_TIMER;

enum {
	TIMER_MODE_FREE = 0,
	TIMER_MODE_CYCLE = 1,
};

enum {
	TIMER_INT_UNMASK = 0,
	TIMER_INT_MASK = 1,
};
