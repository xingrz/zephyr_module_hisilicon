OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    STACK(rwx)              : ORIGIN = 0x00100000               , LENGTH = 8K
    HEAP(rwx)               : ORIGIN = 0x00100000 + 20K         , LENGTH = 20K
    LOADER_BOOT(rx)         : ORIGIN = 0x00100000 + 40K + 0x040 , LENGTH = 80K
    FIXED_ROM(rx)           : ORIGIN = 0x00000000 + 11K         , LENGTH = 21K
    CODE_ROM(rx)            : ORIGIN = 0x003b8000 + 278K        , LENGTH = 10K
}

STACK_SIZE      = 6k;
NMI_STACK_SIZE  = 2K;

SECTIONS
{
    .text.entry : ALIGN(4)
    {
        KEEP(*(.text.entry))
    } > LOADER_BOOT

    .rom.code.text :
    {
        . = ALIGN(4);
        KEEP(SORT(libcodebase.o)(.text*))
        KEEP(SORT(libcodebase.o)(.rodata*))
        . = ALIGN(4);
    } > CODE_ROM

    .stacks (NOLOAD) :
    {
        . = ALIGN(4);
        __SYSTEM_STACK_BEGIN__ = ORIGIN(STACK);
        KEEP(*(.stacks))
        __SYSTEM_STACK_END__ = ORIGIN(STACK) + STACK_SIZE;
        . = ALIGN(0x20);
        __nmi_stack_bottom = .;
        . += NMI_STACK_SIZE;
        __nmi_stack_top = .;
    } > STACK
    __SYSTEM_STACK_SIZE__ = __SYSTEM_STACK_END__ - __SYSTEM_STACK_BEGIN__;
    __stack_top = __SYSTEM_STACK_END__;

    .rom.data :
    {
        . = ALIGN(4);
        __rom_copy_start = LOADADDR(.rom.data);
        . = ALIGN(4);
        __rom_copy_ram_start = .;
        __global_pointer$ = .;
        KEEP(SORT(libbase.o) (.data*))
        . = ALIGN(4);
        __rom_copy_ram_end = .;
    } > FIXED_ROM
    __rom_copy_size = __rom_copy_ram_end - __rom_copy_ram_start;

    .rom.code.data :
    {
        . = ALIGN(4);
        __code_rom_copy_start = LOADADDR(.rom.code.data);
        . = ALIGN(4);
        __code_rom_copy_ram_start = .;
        KEEP(SORT(libcodebase.o) (.data*))
        . = ALIGN(4);
        __code_rom_copy_ram_end = .;
    } > CODE_ROM
    __code_rom_copy_size = __code_rom_copy_ram_end - __code_rom_copy_ram_start;

    .rom.code.bss :
    {
        . = ALIGN(4);
        __code_rom_bss_start = .;
        KEEP(libcodebase.o (.bss))
        KEEP(libcodebase.o (.bss*))
        KEEP(libcodebase.o (COMMON))
        . = ALIGN(4);
        __code_rom_bss_end = .;
    } > CODE_ROM

    .text : ALIGN(4)
    {
        __start = .;
        *(.text*)
        *(.ram.text*)
        . = ALIGN(4);
        __rodata_start = .;
        *(.rodata*)
        . = ALIGN(4);
        __rodata_end = .;
        __text_end = .;
    } > LOADER_BOOT

    .data : ALIGN(4)
    {
        __data_load = LOADADDR(.data);
        __data_start = .;
        *(.data*)
        . = ALIGN(4);
        __data_end = .;
    } > LOADER_BOOT

    .bss (NOLOAD) : ALIGN(4)
    {
        __bss_begin__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > LOADER_BOOT
    __bss_size__ = __bss_end__ - __bss_begin__;

    .heap (NOLOAD) :
    {
        . = ALIGN(4);
        __heap_begin__ = ORIGIN(HEAP);
        KEEP(*(.heap))
        __heap_end__ =  __heap_begin__ + LENGTH(HEAP);
    } > HEAP
}
