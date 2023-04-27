# Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
# SPDX-License-Identifier: Apache-2.0

add_subdirectory_ifdef(CONFIG_SOC_SERIES_HI3861 hi3861)

zephyr_include_directories_ifdef(CONFIG_HISILICON include)
