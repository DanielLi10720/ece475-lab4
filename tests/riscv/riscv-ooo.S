//========================================================================
// riscv-ooo.S.S
//========================================================================

#include "riscv-macros.h"
    TEST_RISCV_BEGIN
    // Test out-of-order capability
    li x1, 1
    li x2, 2
    mul x1, x1, x2 // x1 should contain 2
    mul x2, x1, x2 // x2 should contain 4
    li x2, 1 // set x1 as 1, should commit before the mul
    TEST_INSERT_NOPS(4) // wait for the mul to commit
    add x3, x1, x2 // should be 2 + 1 = 3, will actually be 2 + 4 = 6
    TEST_CHECK_EQ( x3, 3)

    // test v2
    
    
    TEST_RISCV_END
