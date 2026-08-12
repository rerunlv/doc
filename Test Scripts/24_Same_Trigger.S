.text

# Defined priority: lowest matching AP index wins.
#
# Exit codes:
# 0 = PASS: AP0 fired
# 1 = AP1 incorrectly fired
# 2 = APLASTEX did not identify AP0
# 3 = No preemption

.equ mach_active, 0x80000001

.global _start

handler0:
    csrr t0, aplastex
    bnez t0, wrong_lastex

    li a0, 0
    j exit

handler1:
    li a0, 1
    j exit

_start:
    csrwi apstatus, 1

    # Configure AP0/AP1 to same trigger
    csrwi apselect, 0
    li t0, mach_active
    csrw apctrl, t0
    la t0, shared_trigger
    csrw aptrig, t0
    la t0, handler0
    csrw aptar, t0

    csrwi apselect, 1
    li t0, mach_active
    csrw apctrl, t0
    la t0, shared_trigger
    csrw aptrig, t0
    la t0, handler1
    csrw aptar, t0

shared_trigger:
    li a0, 3
    j exit

wrong_lastex:
    li a0, 2

exit:
    li a7, 93
    ecall