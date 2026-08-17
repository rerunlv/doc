.text

# Exit codes:
# 0 = PASS
# 1 = Invalid window read was nonzero
# 2 = Invalid window write corrupted AP0

.equ ap0_ctrl, 0x80000001
.equ ap0_trig, 0x00001000
.equ ap0_tar,  0x00002000

.global _start

_start:
    csrwi apselect, 0

    li t0, ap0_ctrl
    csrw apctrl, t0
    li t0, ap0_trig
    csrw aptrig, t0
    li t0, ap0_tar
    csrw aptar, t0

    # NUM_ANTICIPATION_POINTS is 8, so index 13 is invalid.
    csrwi apselect, 13

    csrr t0, apctrl
    bnez t0, invalid_read
    csrr t0, aptrig
    bnez t0, invalid_read
    csrr t0, aptar
    bnez t0, invalid_read

    # These writes must be ignored.
    li t0, -1
    csrw apctrl, t0
    csrw aptrig, t0
    csrw aptar, t0

    csrwi apselect, 0

    csrr t0, apctrl
    li t1, ap0_ctrl
    bne t0, t1, ap0_corrupt

    csrr t0, aptrig
    li t1, ap0_trig
    bne t0, t1, ap0_corrupt

    csrr t0, aptar
    li t1, ap0_tar
    bne t0, t1, ap0_corrupt

    li a0, 0
    j exit

invalid_read:
    li a0, 1
    j exit

ap0_corrupt:
    li a0, 2

exit:
    li a7, 93
    ecall