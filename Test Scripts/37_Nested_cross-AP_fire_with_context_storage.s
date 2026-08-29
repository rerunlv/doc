.text
# Test 37: Nested round trip with handler discipline: AP0's handler
# saves APEPC (APSCRATCH or memory) before the nestable region, AP1
# fires and aprets back into AP0's handler, AP0 restores APEPC and
# aprets to the original interrupted point. This is the save/restore
# contract the ISA mod pushes onto software, and the most
# BUNDLE-relevant test in the plan.
# 
# Exit codes:
#   0 = PASS
#   1 = Failure to preempt AP0
#   2 = Failure to preempt AP1



.equ mach_active, 0x80000001

.global _start

target0:
	# store APEPC to APSCRATCH
	csrr t1, apepc
	csrw apscratch, t1
	
	li t1, 0
trigger1:
    beqz t1, failure2
	
	# Restore APEPC from APSCRATCH
	csrr t1, apscratch
	csrw apepc, t1
	
	apret
	
target1:
	li t1,1
	apret

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
	
    li a0, 1
trigger0:
    li a7, 93
    ecall

failure2:
    li a0, 2
    li a7, 93
    ecall	