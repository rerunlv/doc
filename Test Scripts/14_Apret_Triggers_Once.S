.text

# Test 14:
# After APRET with APS set:
#   1. The trigger instruction executes exactly once.
#   2. Executing that instruction clears APS.
#
# Exit codes:
#   0 = Pass
#   1 = Fail, No initial preemption
#   2 = Fail, Trigger instruction did not execute exactly once
#   3 = Fail, APS was not cleared

.equ mach_active, 0x80000001
.equ aps_mask,    0x00000004

.global _start

target:
    # Record that the handler ran.
    li s1, 1

    # Set APS without changing the other APCTRL bits
    csrr t0, apctrl
    ori  t0, t0, aps_mask
    csrw apctrl, t0

    apret

_start:
    csrwi apstatus, 1
    csrwi apselect, 0

    # Trigger execution marker
    li s0, 0
    # Handler execution marker
    li s1, 0                  

    li t0, mach_active
    csrw apctrl, t0

    la t0, target
    csrw aptar, t0

    la t0, trigger
    csrw aptrig, t0

trigger:
    # After APRET, this must execute exactly once
    addi s0, s0, 1

after_trigger:
    # Verify that initial preemption occurred
    li t0, 1
    bne s1, t0, no_preemption

    # Verify that the trigger instruction executed exactly once
    bne s0, t0, count_failure

    # Verify that executing the trigger cleared APS
    csrr t0, apctrl
    andi t0, t0, aps_mask
    bnez t0, aps_failure

pass:
    li a0, 0
    li a7, 93
    ecall

no_preemption:
    li a0, 1
    li a7, 93
    ecall

count_failure:
    li a0, 2
    li a7, 93
    ecall

aps_failure:
    li a0, 3
    li a7, 93
    ecall