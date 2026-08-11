.text

# Test 1: Preemption fires when PC matches APTRIG and AP is active
# 
# Exit codes:
#   0 = PASS
#   1  = No preemption

.equ mach_active, 0x80000001

.global _start

target:
    # Preemption successful
    li a0, 0
    li a7, 93
    ecall

_start:

    csrwi apstatus, 1

    csrwi apselect, 0

    li t1, mach_active
    csrw apctrl, t1

    la t1, target
    csrw aptar, t1
    
    la t1, trigger
    csrw aptrig, t1

trigger:
    # Failure to preempt
    li a0, 1
    li a7, 93
    ecall
