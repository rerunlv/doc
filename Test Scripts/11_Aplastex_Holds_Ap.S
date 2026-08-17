.text

# Test 11: APLASTEX holds the index of the firing AP
#
# AP5 is the only active anticipation point.
#
# Exit codes:
#   0 = PASS: APLASTEX contains 5
#   1 = FAIL: APLASTEX contains the wrong index
#   2 = FAIL: no preemption occurred

.equ selected_ap,   5
.equ number_of_aps, 8
.equ mach_active,   0x80000001
.equ mach_inactive, 0x80000000

.global _start


target:
    # AP5 caused the preemption, so APLASTEX must contain 5.
    csrr t0, aplastex

    li t1, selected_ap
    bne t0, t1, wrong_aplastex

    # PASS
    li a0, 0
    li a7, 93
    ecall


_start:
    # Keep preemption disabled while configuring the lanes.
    csrwi apstatus, 0

    # Explicitly deactivate all eight lanes.
    li t0, 0

disable_loop:
    csrw apselect, t0

    li t1, mach_inactive
    csrw apctrl, t1

    addi t0, t0, 1
    li t1, number_of_aps
    blt t0, t1, disable_loop

    # Configure AP5.
    li t0, selected_ap
    csrw apselect, t0

    li t1, mach_active
    csrw apctrl, t1

    la t1, target
    csrw aptar, t1

    la t1, trigger
    csrw aptrig, t1

    # Enable anticipation after configuration is complete.
    csrwi apstatus, 1


trigger:
    # Reaching this instruction means AP5 did not preempt.
    li a0, 2
    li a7, 93
    ecall


wrong_aplastex:
    li a0, 1
    li a7, 93
    ecall