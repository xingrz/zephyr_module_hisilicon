/*----------------------------------------------------------------------------
 * Copyright (c) <2013-2017>, <Huawei Technologies Co., Ltd>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list
 * of conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used
 * to endorse or promote products derived from this software without specific prior written
 * permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *---------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------
 * Notice of Export Control Law
 * ===============================================
 * Huawei LiteOS may be subject to applicable export control laws and regulations, which might
 * include those applicable to Huawei LiteOS of U.S. and the country in which you are located.
 * Import, export and usage of Huawei LiteOS in any manner by you shall be in compliance with such
 * applicable export control laws and regulations.
 *---------------------------------------------------------------------------*/

/*******************************************************************************
 *
 * @file entry.S
 * @author Huawei LiteOS
 * @brief RISC-V trap handling and startup code.
 *
 */
#ifndef ENTRY_S
#define ENTRY_S

.extern __stack_top

#define LREG lw
#define SREG sw
#define REGBYTES 4

#define INT_SIZE_ON_STACK  (16 * REGBYTES)

#define MSTATUS_MPP_MACHINE       0x00001800
#define MCAULSE_ECALL_FROM_MMODE  11
#define MCAULSE_ECALL_FROM_UMODE  8

    .extern trap_entry
    .section      .text.entry
    .global _start
    .option norvc
_start:
    j handle_reset

.macro push_reg
    addi  sp, sp, -(INT_SIZE_ON_STACK)
    stmia {ra, t0-t2, a0-a7, t3-t6}, (sp)
    addi  sp, sp, -(INT_SIZE_ON_STACK)
.endm

.macro pop_reg
    addi  sp, sp, INT_SIZE_ON_STACK
    ldmia {ra, t0-t2, a0-a7, t3-t6},(sp)
    addi  sp, sp, INT_SIZE_ON_STACK
.endm

trap_entry_wrapper:
    j trap_entry

trap_entry:
    push_reg
    csrr t0, mcause
#ecall from M-mode
    li t1, MCAULSE_ECALL_FROM_MMODE
    bne t0, t1, 1f
    li t2, MSTATUS_MPP_MACHINE
    csrc mstatus, t2
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    pop_reg
    mret
#ecall from U-mode
1:
    li t1, MCAULSE_ECALL_FROM_UMODE
    bne t0, t1, 2f
    li t2, MSTATUS_MPP_MACHINE
    csrs mstatus, t2
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    pop_reg
    mret
#Other exception. //TODO: reg reset.
2:
    pop_reg
    j trap_entry

handle_reset:
    csrwi mstatus, 0
    csrwi mie, 0
    csrci mstatus, 0x08

/* initialize global pointer */
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

/* initialize stack pointer */
    la sp, __stack_top

/* perform the rest of initialization in C */
clear_bss:
    la t0, __bss_begin__
    la t1, __bss_end__
    li t2, 0x00000000

clear_bss_loop:
    sw      t2, (t0)        /* clear BSS location */
    addi t0, t0, 4          /* increment clear index pointer */
    blt     t0, t1, clear_bss_loop  /* are we at the end yet, if not , contiue till the end */

clear_rom_bss:
    la t0, __rom_bss_start
    la t1, __rom_bss_end
    li t2, 0x00000000

clear_rom_bss_loop:
    sw      t2, (t0)        /* clear ROM_BSS location */
    addi    t0, t0, 4       /* increment clear index pointer */
    blt     t0, t1, clear_rom_bss_loop /* are we at the end yet, if not , contiue till the end */

clear_code_rom_bss:
    la t0, __code_rom_bss_start
    la t1, __code_rom_bss_end
    li t2, 0x00000000

clear_code_rom_bss_loop:
    sw      t2, (t0)        /* clear ROM_BSS location */
    addi    t0, t0, 4       /* increment clear index pointer */
    blt     t0, t1, clear_code_rom_bss_loop /* are we at the end yet, if not , contiue till the end */

/* copy .data .sdata section  from  FIX_ROM to SRAM */
    la t0, __rom_copy_ram_start /* SRAM addr */
    la t1, __rom_copy_start     /* ROM addr  */
    la t2, __rom_copy_size
    add t2, t2, t1

start_fixrom_data_loop:
    lw t3, (t1)
    sw t3, (t0)
    addi t0, t0, 4
    addi t1, t1, 4
    blt t1, t2, start_fixrom_data_loop /* are we at the end yet, if not , contiue till the end */
end_fixrom_data_loop:

/* copy .data .sdata section  from  CODE_ROM to SRAM */
    la t0, __code_rom_copy_ram_start /* SRAM addr */
    la t1, __code_rom_copy_start     /* ROM addr  */
    la t2, __code_rom_copy_size
    add t2, t2, t1

start_coderom_data_loop:
    lw t3, (t1)
    sw t3, (t0)
    addi t0, t0, 4
    addi t1, t1, 4
    blt t1, t2, start_coderom_data_loop /* are we at the end yet, if not , contiue till the end */
end_coderom_data_loop:


/* pmp init */
pmp_init:
    li t0, 0xB00
    csrw pmpaddr0, t0
    li t0,0x2000
    csrw pmpaddr1, t0 /* (1)11-32K(0x8000) fixrom: disable w;non-cacheable */
#ifdef HI_BOARD_ASIC
    li t0,0x477f0
    csrw pmpaddr2, t0 /* (2)32k(0x8000) - 0x11DFC0 RAM: disable x;non-cacheable */
    li t0,0x47800
    csrw pmpaddr3, t0 /* (3)0x11DFC0 - 0x11E000 checkinfo: disable w x;non-cacheable */
#else
    li t0,0x7fff0
    csrw pmpaddr2, t0 /* (2)32k(0x8000) - 0x1FFFC0 RAM: non-cacheable */
    li t0,0x80000
    csrw pmpaddr3, t0 /* (3)0x1FFFC0 - 0x200000 checkinfo: disable w x;non-cacheable */
#endif
    li t0,0xEE000
    csrw pmpaddr4, t0 /* (4)0x11E000 - 0x3B8000 another romboot: disable r-w-x;non-cacheable */
    li t0,0xFF600
    csrw pmpaddr5, t0 /* (5)0x3B8000 - 0x3FD800 kernel_rombin: diasble r-w-x;non-cacheable */
    li t0,0x100000
    csrw pmpaddr6, t0 /* (6)0x3FD800 - 0x400000 code_rombin(9K): diasble w;non-cacheable */
    li t0,0x18000000
    csrw pmpaddr7, t0 /* (7)0x400000 -> 0x60000000 REG: disable x;non-cacheable */

    li t0,0xf3333333  /* f:Write-back Read and Write-allocate; 3:Normal Non-cacheable Bufferable */
    csrw 0x7d8,t0

    li t0,0x090f0d88  /* 0x0d:TOR-R-X; 0x0b:TOR-R-W; 0x08:TOR; 0x0c:TOR-x; 0x09:TOR-R */
    csrw pmpcfg0,t0
    li t0,0x0b0d0808
    csrw pmpcfg1,t0

/* disable Icache */
    csrwi  0x7C0, 0x0 /* disable ICACHE */
    fence

/* disable Dcache */
    csrwi  0x7C1, 0x0 /* disable DCACHE */
    fence

    csrwi mstatus, 0
    csrwi mie, 0
    la t0, trap_entry_wrapper
    addi t0, t0, 1
    csrw mtvec, t0
    ecall        /* ecall: M-mode -> U-mode */

/* jump to C func. */
    tail start_fastboot
#endif
