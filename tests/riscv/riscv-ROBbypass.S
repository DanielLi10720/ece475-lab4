//========================================================================
// riscv-ROBbypass.S
//========================================================================

#include "riscv-macros.h"
    TEST_RISCV_BEGIN
    // Test bypassing out of the ROB
    li x1, 1
    li x2, 2
    mul x1, x1, x2 // x1 should contain 2, should take a bit of time to be able to commit
    addi x3, x2, 1 // x3 should contain 3, should be writtenback to ROB before the mul on previous line commits
    addi x4, x3, 1 // x4 should contain 4, should bypass from the ROB
    TEST_CHECK_EQ( x4, 4)
    TEST_RISCV_END