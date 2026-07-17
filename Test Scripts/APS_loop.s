.text

.equ mach_inactive, 	0x80000000		# Here, the '8' represents a one in the M position of apctrl
.equ mach_active, 		0x80000001		# The '1' is the "active" bit of apctrl
.equ aps_mask,			0x00000002		# This is the bitmask for the semaphore of the anticipation point.
.equ mach_act_sem, 		0x80000003		# This is the & of aps_mask and mach_active

target:									# Handler Address
	addi t0, t0, 1

	bgt t2, zero, skip					# while t2 > 0, don't set APS
	
	li t1, mach_act_sem					# Setting the APS with `active`
	csrw apctrl, t1

skip:
	addi t2, t2, -1						
	apret								# Pseudo-instruction for `apret zero, 0`

.global _start							# Standard way of telling the linking the baremetal code starts here.
_start:

li t2, 8

csrwi apstatus, 1
csrwi apselect, 0
li t1, mach_active
csrw apctrl, t1
la t1, target
csrw aptar, t1

la t1, trigger
csrw aptrig, t1

li a0, 0
li t0, 0

trigger:
	add a0, a0, t0

li a7, 93
ecall
