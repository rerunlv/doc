.text

# Exit codes:
# 0 = PASS
# 1 = AP0 reported wrong APLASTEX
# 2 = AP1 fired before AP0
# 3 = AP1 reported wrong APLASTEX

.equ mach_active,   0x80000001
.equ mach_inactive, 0x80000000

.global _start

handler0:
    csrr t0, aplastex
    bnez t0, wrong_ap0

    li s0, 1

    # Disable AP0 so returning to trigger0 cannot retrigger.
    csrwi apselect, 0
    li t0, mach_inactive
    csrw apctrl, t0

    apret

handler1:
    # AP0 must already have fired.
    li t0, 1
    bne s0, t0, ap1_too_early

    csrr t0, aplastex
    li t1, 1
    bne t0, t1, wrong_ap1

    li a0, 0
    j exit

_start:
    csrwi apstatus, 1
    li s0, 0

    # Configure AP0.
    csrwi apselect, 0
    li t0, mach_active
    csrw apctrl, t0
    la t0, trigger0
    csrw aptrig, t0
    la t0, handler0
    csrw aptar, t0

    # Configure AP1.
    csrwi apselect, 1
    li t0, mach_active
    csrw apctrl, t0
    la t0, trigger1
    csrw aptrig, t0
    la t0, handler1
    csrw aptar, t0

trigger0:
    nop

trigger1:
    li a0, 4                    # Neither AP handled correctly.
    j exit

wrong_ap0:
    li a0, 1
    j exit

ap1_too_early:
    li a0, 2
    j exit

wrong_ap1:
    li a0, 3

exit:
    li a7, 93
    ecall