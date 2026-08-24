.text

# Defined priority: lowest matching AP index wins.
#
# Exit codes:
# 0 = PASS: AP1fired
# 1 = AP1 did not fire

.equ mach_inactive, 0x80000000
.equ mach_active,   0x80000001

.global _start

target:
    # Disable AP0
    csrwi apselect, 0

    li t0, mach_inactive
    csrw apctrl, t0

    # Configure AP1
    csrwi apselect, 1

    li t0, mach_active
    csrw apctrl, t0

    la t0, target2
    csrw aptar, t0

    la t0, trigger2
    csrw aptrig, t0

    apret

target2:
    # Pass
    li a0, 0
    j exit

_start:
    csrwi apstatus, 1

    # Configure AP0
    csrwi apselect, 0

    li t0, mach_active
    csrw apctrl, t0

    la t0, target
    csrw aptar, t0

    la t0, trigger
    csrw aptrig, t0

trigger:
    nop
    
trigger2:
    # Fail
    li a0, 1

exit:
    li a7, 93
    ecall