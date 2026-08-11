.text

# Test 7: APTRIG is the same address as APTAR
#
# Exit codes:
#   0 = Pass preemption updated APEPC
#   1 = Fail address reached without preemption

.equ mach_active, 0x80000001

.global _start

_start:
    csrwi apstatus, 1
    csrwi apselect, 0

    csrw apepc, zero

    li t1, mach_active
    csrw apctrl, t1

    la t1, trigger_target
    csrw aptar, t1
    csrw aptrig, t1

trigger_target:
    # Both fall-through and redirection reach this address.
    # APEPC distinguishes whether preemption occurred.
    csrr t2, apepc
    la t3, trigger_target
    bne t2, t3, fail

pass:
    li a0, 0
    li a7, 93
    ecall

fail:
    li a0, 1
    li a7, 93
    ecall