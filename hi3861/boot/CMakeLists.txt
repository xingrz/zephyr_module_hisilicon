# Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
# SPDX-License-Identifier: Apache-2.0

set(COMMONBOOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/commonboot)
set(
    COMMONBOOT_SRCS
    ${COMMONBOOT_DIR}/efuse/efuse_drv.c
    ${COMMONBOOT_DIR}/flash/flash_hw_process_flashboot.c
)

set(UBOOT_DIR ${ZEPHYR_CURRENT_MODULE_DIR}/hi3861/boot/u-boot-v2019.07)
set(
    UBOOT_SRCS
    ${UBOOT_DIR}/lib/crc32.c
    ${UBOOT_DIR}/lib/lzma/LzmaDec.c
    ${UBOOT_DIR}/lib/lzma/LzmaTools.c
)

set(BOOT_LIBS_DIR ${ZEPHYR_CURRENT_MODULE_DIR}/zephyr/blobs/lib/hi3861)

set(
    BOOT_CFLAGS
    -freorder-blocks-algorithm=simple -fno-schedule-insns -nostdinc
    -fno-aggressive-loop-optimizations -fno-builtin -fno-exceptions
    -fno-short-enums -mtune=size -msmall-data-limit=0 -Wall -Werror -Os -std=c99
    -falign-functions=2 -fdata-sections -ffunction-sections -fno-common
    -fstack-protector-strong
    -DHI_BOARD_ASIC
    -DCONFIG_COMPRESSION_OTA_SUPPORT
    -DCONFIG_QUICK_SEND_MODE
)

set(SIGN_BIN_PY ${CMAKE_CURRENT_SOURCE_DIR}/sign_bin.py)

add_subdirectory(flashboot)
add_subdirectory(loaderboot)
