.text

# Test 5d: Trigger address reached with Jalr
#
# Exit codes:
#   0 = PASS, preemption occurred
#   1 = FAIL, trigger reached without preemption

.equ mach_active, 0x80000001

.global _start

target:
    li a0, 0
    li a7, 93
    ecall

_start:
    csrwi apstatus, 1
    csrwi apselect, 0

    li t1, mach_active
    csrw apctrl, t1

    la t1, target
    csrw aptar, t1

    la t1, trigger
    csrw aptrig, t1

# Jalr check
    la t2, trigger
    jalr ra, 0(t2)

# Fail, branch unexpectedly not taken
    li a0, 1
    li a7, 93
    ecall

trigger:
    # Pass, correct jump
    li a0, 0
    li a7, 93
    ecall
