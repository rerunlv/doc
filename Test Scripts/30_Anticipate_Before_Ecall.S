.text

# Test 30: Anticipation versus ECALL
#
# ECALL is trigger
#
# Expected sequence:
#   1. Initial arrival at ECALL causes preemption.
#   2. Handler changes a0 from 1 to 0 and sets APS.
#   3. APRET returns to the ECALL.
#   4. APS admits the ECALL exactly once.
#   5. ECALL exits with code 0.
#
# Exit codes:
#   0 = Pass preemption occurred before ECALL
#   1 = Fail ECALL executed before preemption

.equ mach_active, 0x80000001
.equ aps_mask,    0x00000004

.global _start

target:
    # Reaching the handler proves anticipation won.
    li s0, 1

    # Change the eventual ECALL exit code to PASS.
    li a0, 0

    # Set APS while preserving the other APCTRL fields.
    csrr t0, apctrl
    ori  t0, t0, aps_mask
    csrw apctrl, t0

    apret


_start:
    csrwi apselect, 0

    # Marker to check if anticipation occured
    li s0, 0

    li t0, mach_active
    csrw apctrl, t0

    la t0, target
    csrw aptar, t0

    la t0, trigger_ecall
    csrw aptrig, t0

    # Fail, ECALL executes before preemption if a0 stays as 1
    li a0, 1
    li a7, 93

    csrwi apstatus, 1


trigger_ecall:
    ecall