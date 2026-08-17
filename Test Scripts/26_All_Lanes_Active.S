.text

# Test: All eight AP lanes preempt independently
#
# Each lane has:
#   - active = 1
#   - a unique APTRIG
#   - the common handler as APTAR
#
# Expected firing order:
#   AP0, AP1, AP2, AP3, AP4, AP5, AP6, AP7
#
# Exit codes:
#   0 = PASS
#   1 = APLASTEX reported the wrong lane
#   2 = Not all eight APs fired

.equ number_of_lanes, 8
.equ mach_active,     0x80000001
.equ aps_mask,        0x00000004

.global _start


# Configure one AP lane.
.macro configure_lane lane, trigger_address
    csrwi apselect, \lane

    li t0, mach_active
    csrw apctrl, t0

    la t0, \trigger_address
    csrw aptrig, t0

    la t0, common_handler
    csrw aptar, t0
.endm


common_handler:
    # APLASTEX must equal the next expected lane index.
    csrr t0, aplastex
    bne t0, s0, wrong_aplastex

    # Count this lane as successfully fired.
    addi s0, s0, 1

    # Select the lane that caused this preemption.
    csrw apselect, t0

    # Set APS for that lane without changing its other fields.
    # This allows its trigger instruction to execute once after APRET.
    csrr t1, apctrl
    ori  t1, t1, aps_mask
    csrw apctrl, t1

    apret


_start:
    # Prevent preemption during configuration.
    csrwi apstatus, 0

    # Next expected lane index and total preemption count.
    li s0, 0

    configure_lane 0, trigger0
    configure_lane 1, trigger1
    configure_lane 2, trigger2
    configure_lane 3, trigger3
    configure_lane 4, trigger4
    configure_lane 5, trigger5
    configure_lane 6, trigger6
    configure_lane 7, trigger7

    # Enable anticipation after all lanes are configured.
    csrwi apstatus, 1


trigger0:
    nop

trigger1:
    nop

trigger2:
    nop

trigger3:
    nop

trigger4:
    nop

trigger5:
    nop

trigger6:
    nop

trigger7:
    nop

    # All eight handlers must have executed.
    li t0, number_of_lanes
    bne s0, t0, incomplete_failure

pass:
    li a0, 0
    li a7, 93
    ecall


wrong_aplastex:
    li a0, 1
    li a7, 93
    ecall


incomplete_failure:
    li a0, 2
    li a7, 93
    ecall