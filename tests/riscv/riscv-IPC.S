#include "riscv-macros.h"

TEST_RISCV_BEGIN

    la   x1, chain_data       # base pointer
    li   x28, 0               # accumulator (to prevent DCE)
    li   x29, 64              # loop count — enough to fill ROB repeatedly

loop:
    lw   x2,  0(x1)
    lw   x3,  0(x2)
    lw   x4,  0(x3)
    lw   x5,  0(x4)
    lw   x6,  0(x5)
    lw   x7,  0(x6)          


    li   x8,  1;  li x9,  2;  li x10, 3;  li x11, 4
    li   x12, 5;  li x13, 6;  li x14, 7;  li x15, 8

    add  x16, x8,  x9
    add  x17, x10, x11
    add  x18, x12, x13
    add  x19, x14, x15
    mul  x20, x16, x17
    mul  x21, x18, x19
    mul  x22, x20, x21
    add  x23, x22, x22
    mul  x24, x23, x23
    add  x25, x24, x23
    mul  x26, x25, x24
    add  x27, x26, x25


    # --------------------------------------------------
    # Loop branch depends on x7 (end of load chain)
    # OOO cannot resolve this branch until x7 is ready.
    # Even with branch prediction, it can only speculate
    # ROB-size instructions ahead before stalling fetch.
    # --------------------------------------------------
    add  x28, x28, x7         # use x7 to prevent optimization
    addi x29, x29, -1
    bnez x29, loop            # branch depends on x29 (resolves fast)
                               # but x28 pollutes commit ordering

    TEST_CHECK_EQ(x28, 33577472)     # update expected value for your data

TEST_RISCV_END

.data
.align 4
chain_data:
    # Pointer chain: each entry holds address of next entry
    # All in L1 cache (close together) but still load latency bound
    .word chain_data + 4
    .word chain_data + 8
    .word chain_data + 12
    .word chain_data + 16
    .word chain_data + 20
    .word chain_data + 24
    .word chain_data          # wrap back to start