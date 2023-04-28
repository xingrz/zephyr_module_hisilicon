# Copyright (c) 2023 Chen Xingyu <hi@xingrz.me>
# SPDX-License-Identifier: Apache-2.0

project(flashboot C ASM)

add_executable(flashboot)

file(
    GLOB BOOT_SRCS
    startup/*.S
    startup/*.c
    drivers/lsadc/*.c
    drivers/flash/*.c
    drivers/efuse/*.c
    drivers/gpio/*.c
    drivers/io/*.c
    common/nvm/*.c
    common/partition_table/*.c
    upg/*.c
    lib/lzma/*.c
    lzmaram/*.c
    secure/*.c
)

target_sources(flashboot PRIVATE ${BOOT_SRCS})
target_sources(flashboot PRIVATE ${COMMONBOOT_SRCS})
target_sources(flashboot PRIVATE ${UBOOT_SRCS})

target_include_directories(flashboot PRIVATE upg)
target_include_directories(flashboot PRIVATE include)
target_include_directories(flashboot PRIVATE drivers/lsadc)
target_include_directories(flashboot PRIVATE drivers/gpio)
target_include_directories(flashboot PRIVATE drivers/io)
target_include_directories(flashboot PRIVATE drivers/efuse)
target_include_directories(flashboot PRIVATE secure)
target_include_directories(flashboot PRIVATE ${COMMONBOOT_DIR})

target_compile_options(flashboot PRIVATE ${TOOLCHAIN_C_FLAGS})
target_compile_options(flashboot PRIVATE ${BOOT_CFLAGS})

target_link_options(flashboot PRIVATE -nostdlib -nostartfiles -Wl,--gc-sections)
target_link_options(flashboot PRIVATE -L ${BOOT_LIBS_DIR})
target_link_options(flashboot PRIVATE -T ${CMAKE_CURRENT_SOURCE_DIR}/flashboot_sha256.lds)

add_custom_command(
    OUTPUT  flashboot.bin
    COMMAND ${CMAKE_OBJCOPY}
    ARGS    -O binary
            -S
            -R .rom.text -R .rom.code.text
            -R .rom.data -R .rom.code.data
            -R .rom.bss  -R .rom.code.bss
            flashboot.elf
            flashboot.bin
    COMMAND ${PYTHON_EXECUTABLE} ${SIGN_BIN_PY}
    ARGS    flashboot.bin
    DEPENDS flashboot.elf
)

add_custom_target(
    build_flashboot
    DEPENDS flashboot.bin
)

add_dependencies(app build_flashboot)
