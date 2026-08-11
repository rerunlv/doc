.text

# Test 1: Preemption fires when PC matches APTRIG and AP is active
# 
# Exit codes:
#   0 = PASS
#   1 = Jumps to trigger
#   2 = Jumps to target

.equ mach_inactive, 0x80000000

.global _start

target:
    # Fail, jumps to target
    li a0, 1
    li a7, 93
    ecall

_start:

    csrwi apstatus, 1

    csrwi apselect, 0

    # Set AP not active
    li t1, mach_inactive
    csrw apctrl, t1

    la t1, target
    csrw aptar, t1
    
    la t1, trigger
    csrw aptrig, t1

trigger:
    # Pass, does not preempt
    li a0, 0
    li a7, 93
    ecall
