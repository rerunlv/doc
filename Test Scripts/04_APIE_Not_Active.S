.text

# Test 4: No preemption when APIE = 0, even with AP active
# 
# Exit codes:
#   0 = PASS, trigger reached without preemption
#   1 = Jumps to target

.equ mach_active, 0x80000001

.global _start

target:
    # Fail, jumps to target
    li a0, 1
    li a7, 93
    ecall

_start:
    # Set APIE not active
    csrwi apstatus, 0

    csrwi apselect, 0

    # Set AP active
    li t1, mach_active
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
