.text

# Exit codes:
# 0 = PASS
# 1 = AP1 incorrectly saw AP0 values
# 2 = AP0 values were not preserved

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

    # AP1 should initially contain zeros.
    csrwi apselect, 1

    csrr t0, apctrl
    bnez t0, ap1_leak
    csrr t0, aptrig
    bnez t0, ap1_leak
    csrr t0, aptar
    bnez t0, ap1_leak

    # Switch back and verify AP0 persisted.
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

ap1_leak:
    li a0, 1
    j exit

ap0_corrupt:
    li a0, 2

exit:
    li a7, 93
    ecall