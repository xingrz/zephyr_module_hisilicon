# Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
# SPDX-License-Identifier: Apache-2.0

project(loaderboot C ASM)

add_executable(loaderboot)

file(
    GLOB BOOT_SRCS
    startup/*.S
    startup/*.c
    drivers/lsadc/*.c
    drivers/flash/*.c
    drivers/efuse/*.c
    common/*.c
    common/nvm/*.c
    common/partition_table/*.c
    secure/*.c
)

target_sources(loaderboot PRIVATE ${BOOT_SRCS})
target_sources(loaderboot PRIVATE ${COMMONBOOT_SRCS})
target_sources(loaderboot PRIVATE ${UBOOT_SRCS})

target_include_directories(loaderboot PRIVATE include)
target_include_directories(loaderboot PRIVATE fixed/include)
target_include_directories(loaderboot PRIVATE secure)
target_include_directories(loaderboot PRIVATE ${COMMONBOOT_DIR})

target_compile_options(loaderboot PRIVATE ${TOOLCHAIN_C_FLAGS})
target_compile_options(loaderboot PRIVATE ${BOOT_CFLAGS})

target_link_options(loaderboot PRIVATE -nostdlib -nostartfiles -Wl,--gc-sections)
target_link_options(loaderboot PRIVATE -L ${BOOT_LIBS_DIR})
target_link_options(loaderboot PRIVATE -T ${CMAKE_CURRENT_SOURCE_DIR}/loaderboot_sha256.lds)

add_custom_command(
    OUTPUT  loaderboot.bin
    COMMAND ${CMAKE_OBJCOPY}
    ARGS    -O binary
            -S
            -R .rom.text -R .rom.code.text
            -R .rom.data -R .rom.code.data
            -R .rom.bss  -R .rom.code.bss
            loaderboot.elf
            loaderboot.bin
    COMMAND ${PYTHON_EXECUTABLE} ${SIGN_BIN_PY}
    ARGS    loaderboot.bin
    DEPENDS loaderboot.elf
)

add_custom_target(
    build_loaderboot
    DEPENDS loaderboot.bin
)

add_dependencies(app build_loaderboot)
