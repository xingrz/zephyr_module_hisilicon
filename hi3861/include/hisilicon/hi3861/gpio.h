/*
 * Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <stdint.h>

typedef struct {
	/* 0x00 */ volatile uint32_t SWPORT_DR;
	/* 0x04 */ volatile uint32_t SWPORT_DDR;
	/* 0x08 */ volatile uint32_t __RESERVED0[10];
	/* 0x30 */ volatile uint32_t INTEN;
	/* 0x34 */ volatile uint32_t INTMASK;
	/* 0x38 */ volatile uint32_t INTTYPE_LEVEL;
	/* 0x3C */ volatile uint32_t INT_POLARITY;
	/* 0x40 */ volatile uint32_t INTSTATUS;
	/* 0x44 */ volatile uint32_t RAW_INTSTATUS;
	/* 0x48 */ volatile uint32_t __RESERVED1;
	/* 0x4C */ volatile uint32_t PORT_EOI;
	/* 0x50 */ volatile uint32_t EXT_PORT;
} HI3861_GPIO;
