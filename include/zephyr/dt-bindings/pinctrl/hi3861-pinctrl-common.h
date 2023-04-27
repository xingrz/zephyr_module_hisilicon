/*
 * Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#define HI3861_SIGNAL_POS  0
#define HI3861_SIGNAL_MASK 0x3

#define HI3861_PAD_POS	2
#define HI3861_PAD_MASK 0x1F

#define HI3861_DS_DEF_POS  7
#define HI3861_DS_DEF_MASK 0x7

#define HI3861_DS_MSK_POS  10
#define HI3861_DS_MSK_MASK 0x7

#define HI3861_PINMUX(pad, signal, ds_def, ds_msk)                                                 \
	((pad << HI3861_PAD_POS) | (signal << HI3861_SIGNAL_POS) | (ds_def << HI3861_DS_DEF_POS) | \
	 (ds_msk << HI3861_DS_MSK_POS))
