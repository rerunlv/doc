.text

# Test 13c: APRET clears APCTRL`s pending to 1
#
# Exit codes:
#   0 = PASS: pending cleared
#   1 = FAIL: pending still set
#   2 = FAIL: APRET did not reach APEPC

.equ mach_active_pending, 0x80000003
.equ pending_mask,       0x00000002

.global _start

_start:
    csrwi apselect, 0

    # Set active = 1 and pending = 1.
    li t0, mach_active_pending
    csrw apctrl, t0

    la t0, apret_path
    csrw apepc, t0

    apret

# Fail, Apret does not redirect to APEPC
    li a0, 2
    li a7, 93
    ecall

apret_path:
    csrr t0, apctrl
    andi t0, t0, pending_mask
    bnez t0, pending_failure

    # Pass pending bit is zero
    li a0, 0
    li a7, 93
    ecall

pending_failure:
# Fail, pending is not set to 0
    li a0, 1
    li a7, 93
    ecall