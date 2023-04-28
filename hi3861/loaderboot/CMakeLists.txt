# Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

project(loaderboot C ASM)
set(CMAKE_EXECUTABLE_SUFFIX .elf)

add_executable(loaderboot)

generate_binary(loaderboot)

file(
  GLOB BOOT_SRCS
  startup/*.S
  startup/*.c
  drivers/lsadc/*.c
  drivers/flash/*.c
  drivers/efuse/*.c
  common/*.c
  common/efuse/*.c
  common/flash/*.c
  common/nvm/*.c
)

target_sources(loaderboot PRIVATE ${BOOT_SRCS})

target_compile_options(loaderboot PRIVATE -DHI_BOARD_ASIC)
target_compile_options(loaderboot PRIVATE -DCONFIG_COMPRESSION_OTA_SUPPORT)
target_compile_options(loaderboot PRIVATE -DCONFIG_QUICK_SEND_MODE)

target_include_directories(loaderboot PRIVATE common)
target_include_directories(loaderboot PRIVATE include)
target_include_directories(loaderboot PRIVATE fixed/include)
target_include_directories(loaderboot PRIVATE secure)

target_link_options(loaderboot PRIVATE -L ${CMAKE_CURRENT_SOURCE_DIR}/libs)
target_link_options(loaderboot PRIVATE -T ${CMAKE_CURRENT_SOURCE_DIR}/loaderboot_sha256.lds)
target_link_options(loaderboot PRIVATE -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/loaderboot.map)
