.text

# Test 36: Nested cross-AP fire: AP1's trigger inside AP0's
# handler, both active → AP1 fires mid-handler. Verify APEPC
# and APLASTEX are overwritten by the nested fire (single
# shared registers, by design).
# 
# Exit codes:
#   0 = PASS
#   1  = No preemption

.equ mach_active, 0x80000001

.global _start

target0:
    # Preemption successful
    li a0, 0
    li a7, 93
    ecall
	
target1:
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
