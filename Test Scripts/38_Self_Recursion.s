.text

.equ mach_inactive, 	0x80000000		# Here, the '8' represents a one in the M position of APCTRL
.equ mach_active, 		0x80000001		# The '1' is the "active" bit of APCTRL
.equ active_mask,		0x00000001
.equ aps_mask,			0x00000004		# Bit 2 is APS semaphore in Rev 2
.equ mach_act_sem, 		0x80000005		# M-mode | APS | active

target:									# Handler Address
	addi t0, t0, 1

	bgt t2, zero, skip					# while t2 > 0, don't set APS
	
	li t1, mach_act_sem					# Setting the APS with `active`
	csrw apctrl, t1

skip:
	addi t2, t2, -1			

    j trigger

trigger:
    add t3, t3, t0

    li t1, 9
    bne t0, t1, early_trigger_failure

    bne t3, t1, result_failure

    csrr t1, apctrl
    andi t4, t1, aps_mask
    bnez t4, aps_failure

    andi t4, t1, active_mask
    beqz t4, active_failure

    # PASS
    li a0, 0
    li a7, 93
    ecall


.global _start							# Standard way of telling the linking the baremetal code starts here.
_start:
li t2, 8

csrwi apselect, 0

li t1, mach_active
csrw apctrl, t1

la t1, target
csrw aptar, t1

la t1, trigger
csrw aptrig, t1

li t3, 0
li t0, 0

csrwi apstatus, 1

j target

early_trigger_failure:
    li a0, 1
    li a7, 93
    ecall


result_failure:
    li a0, 2
    li a7, 93
    ecall


aps_failure:
    li a0, 3
    li a7, 93
    ecall


active_failure:
    li a0, 4
    li a7, 93
    ecall
