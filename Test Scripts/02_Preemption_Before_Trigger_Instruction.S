.text

# Test 2: Preemption occurs before the trigger instruction executes.
#
# The trigger instruction increments s0. The handler verifies that s0
# still contains its original value.
#
# Exit codes:
#   0 = PASS: preempted with no register side effect
#   1 = FAIL: trigger instruction executed before preemption
#   2 = FAIL: no preemption occurred

.equ mach_active, 0x80000001
.equ sentinel,    0x12345678

.global _start

target:
    # Verify that the anticipated instruction did not modify s0.
    li t0, sentinel
    bne s0, t0, side_effect_failure

    # PASS
    li a0, 0
    li a7, 93
    ecall

side_effect_failure:
    # Fail, preemption occurrs, only after trigger
    li a0, 1
    li a7, 93
    ecall

_start:
    csrwi apstatus, 1

    li t1, mach_active
    csrw apctrl, t1

    la t1, target
    csrw aptar, t1

    la t1, trigger
    csrw aptrig, t1

    # Establish the value that must remain unchanged
    li s0, sentinel

trigger:
    # Should be preempted
    addi s0, s0, 1

no_preemption:
    # Fail, no redirect occurred.
    li a0, 2
    li a7, 93
    ecall