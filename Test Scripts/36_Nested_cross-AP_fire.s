.text

# Test 36: Nested cross-AP fire: AP1's trigger inside AP0's
# handler, both active → AP1 fires mid-handler. Verify APEPC
# and APLASTEX are overwritten by the nested fire (single
# shared registers, by design).
# 
# Exit codes:
#   0 = PASS
#   1 = Failure to preempt AP0
#   2 = Failure to preempt AP1



.equ mach_active, 0x80000001

.global _start

target0:
    # Preemption successful
    li a0, 2
    li a7, 93
trigger1:
    ecall
	
target1:
    # Preemption successful
    li a0, 0
    li a7, 93
    ecall

_start:

    csrwi apstatus, 1
	
	# Initializing AP0
    csrwi apselect, 0

    la t1, target0
    csrw aptar, t1
    
    la t1, trigger0
    csrw aptrig, t1

    li t1, mach_active
    csrw apctrl, t1

	# Initializing AP1
    csrwi apselect, 1

    la t1, target1
    csrw aptar, t1
    
    la t1, trigger1
    csrw aptrig, t1

    li t1, mach_active
    csrw apctrl, t1

trigger0:
    # Failure to preempt
    li a0, 1
    li a7, 93
    ecall
