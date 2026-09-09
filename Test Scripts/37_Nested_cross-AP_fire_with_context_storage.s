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
#   3 = Failure after returning to AP0 interrupted point

.equ mach_active, 0x80000001
.equ aps_mask,    0x00000004

.global _start

target0:
	# Verify AP0 handler entered first time
	addi s0, s0, 1

	# Store APEPC to APSCRATCH before entering nestable region
	csrr t0, apepc
	csrw apscratch, t0
	
	li t1, 0
trigger1:
	addi t1, t1, 1
	
	# Verify AP1 preempted (s1 == 1) and trigger1 executed (t1 == 1)
	li t0, 1
	bne s1, t0, failure2
	bne t1, t0, failure2
	
	# Restore APEPC from APSCRATCH
	csrr t0, apscratch
	csrw apepc, t0
	
	# Set APS for AP0 before returning so trigger0 can execute
	csrwi apselect, 0
	csrr t2, apctrl
	ori  t2, t2, aps_mask
	csrw apctrl, t2
	
	apret
	
target1:
	addi s1, s1, 1
	
	# Set APS for AP1 before returning so trigger1 can execute
	csrwi apselect, 1
	csrr t2, apctrl
	ori  t2, t2, aps_mask
	csrw apctrl, t2
	
	apret

_start:
	csrwi apstatus, 1
	
	# Initializing registers
	li s0, 0
	li s1, 0
	li s2, 0
	
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
	addi s2, s2, 1

	# Verification after round trip:
	# s0 must be 1 (AP0 fired)
	# s1 must be 1 (AP1 fired)
	# s2 must be 1 (trigger0 executed)
	li t0, 1
	bne s0, t0, failure1
	bne s1, t0, failure2
	bne s2, t0, failure3

	# Success
	li a0, 0
	li a7, 93
	ecall

failure1:
	li a0, 1
	li a7, 93
	ecall

failure2:
	li a0, 2
	li a7, 93
	ecall

failure3:
	li a0, 3
	li a7, 93
	ecall
