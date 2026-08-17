.text

# 16b: Goal: identify problem of `active` being cleared after preempt.

.equ mach_inactive, 	0x80000000		# Here, the '8' represents a one in the M position of APCTRL
.equ mach_active, 		0x80000001		# The '1' is the "active" bit of APCTRL
.equ aps_mask,			0x00000004		# This is the bitmask for the semaphore of the anticipation point.
.equ mach_act_aps, 		0x80000005		# This is the & of aps_mask and mach_active

target:									# Handler Address
	
	blt t1, t0, preempt_2
	
	li t1, 1
	
	csrr t2, apctrl
	andi t2, t2, 1
	beqz t2, fail_1 
	
	li t2, mach_act_aps
	csrw apctrl, t2
	
	apret								# Pseudo-instruction for `apret zero, 0`

preempt_2:
	
	csrr t2, apctrl
	andi t2, t2, 1
	beqz t2, fail_4 
	
	j pass_0

.global _start							# Standard way of telling the linking the baremetal code starts here.
_start:

csrwi apstatus, 1
csrwi apselect, 0

li t1, mach_active
csrw apctrl, t1

la t1, target
csrw aptar, t1

la t1, trigger
csrw aptrig, t1

li t0, 0

loopback:
	li t1, 0
	
trigger:								# Should Preempt twice in total
	add t0, t0, t1

	blt t1, t0, fail_5

	beqz t0, fail_3

	csrr t2, apctrl
	andi t2, t2, 1
	beqz t2, fail_2
	
	csrr t2, apstatus
	andi t2, t2, 1
	beqz t2, fail_7

	j loopback								# force 

pass_0:
	li a0, 0
	li a7, 93
	ecall

fail_1:									# APCTRL->Active cleared on preempt
	li a0, 1
	li a7, 93
	ecall

fail_2:									# APCTRL->Active cleared on APRET
	li a0, 2
	li a7, 93
	ecall

fail_3:									# Failed first preempt
	li a0, 3
	li a7, 93
	ecall

fail_4:									# APCTRL->Active cleared on 2nd preempt
	li a0, 4
	li a7, 93
	ecall

fail_5:									# Failed 2nd preempt

	csrr t2, apctrl
	andi t2, t2, 1
	beqz t2, fail_6
	
	li a0, 5							# ... active was set, APIE was set
	li a7, 93
	ecall
	
fail_6:									# ... active was cleared
	li a0, 6
	li a7, 93
	ecall

fail_7:									# ... APIE was cleared
	li a0, 7
	li a7, 93
	ecall
