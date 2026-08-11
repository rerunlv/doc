.text

# Test: Fill and verify all eight AP lanes
#
# Values:
#   APCTRL[i] = 0x80000000 | i
#   APTRIG[i] = 0x1000 + (i * 0x100)
#   APTAR[i]  = 0x2000 + (i * 0x100)
#
# Exit codes:
#   0 = PASS
#   1 = APCTRL mismatch
#   2 = APTRIG mismatch
#   3 = APTAR mismatch

.equ number_of_lanes, 8
.equ mode_bits,       0x80000000
.equ trig_base,       0x00001000
.equ target_base,     0x00002000

.global _start

_start:
    csrwi apstatus, 0

    # Fill every lane

    li s0, 0                       # Lane index

write_loop:
    csrw apselect, s0

    # APCTRL = 0x80000000 | lane
    li t0, mode_bits
    or t0, t0, s0
    csrw apctrl, t0

    # Offset = lane * 0x100
    slli t1, s0, 8

    # APTRIG = 0x1000 + offset
    li t0, trig_base
    add t0, t0, t1
    csrw aptrig, t0

    # APTAR = 0x2000 + offset
    li t0, target_base
    add t0, t0, t1
    csrw aptar, t0

    addi s0, s0, 1
    li t0, number_of_lanes
    blt s0, t0, write_loop

    # Read and verify every lane

    li s0, 0

verify_loop:
    csrw apselect, s0

    # Verify APCTRL.
    csrr t0, apctrl

    li t1, mode_bits
    or t1, t1, s0

    bne t0, t1, apctrl_failure

    # Calculate lane offset.
    slli t2, s0, 8

    # Verify APTRIG.
    csrr t0, aptrig

    li t1, trig_base
    add t1, t1, t2

    bne t0, t1, aptrig_failure

    # Verify APTAR.
    csrr t0, aptar

    li t1, target_base
    add t1, t1, t2

    bne t0, t1, aptar_failure

    addi s0, s0, 1
    li t0, number_of_lanes
    blt s0, t0, verify_loop


pass:
    # Restore lane 0 as the selected lane.
    csrwi apselect, 0

    li a0, 0
    li a7, 93
    ecall


apctrl_failure:
    li a0, 1
    li a7, 93
    ecall


aptrig_failure:
    li a0, 2
    li a7, 93
    ecall


aptar_failure:
    li a0, 3
    li a7, 93
    ecall