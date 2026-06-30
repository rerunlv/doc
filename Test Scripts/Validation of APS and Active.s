.text

.equ mach_inactive, 	0x80000000		# Here, the '8' represents a one in the M position of APCTRL
.equ mach_active, 		0x80000001		# The '1' is the "active" bit of APCTRL
.equ aps_mask,			0x00000002		# This is the bitmask for the semaphore of the anticipation point.
.equ mach_active_semaphor, 0x80000003	# This is the & of ...

target:	# Handler Address
	li t0, 8
	li t1, mach_active_semaphor
	csrw 0x805, t1
	
	
	apret zero, zero			# Should have pseudo-instruction 

.global _start					# Standard way of telling the linking the baremetal code starts here.
_start:

csrwi 0x800, 1
csrwi 0x804, 0
li t1, mach_active
csrw 0x805, t1
la t1, target
csrw 0x807, t1

la t1, trigger
csrw 0x806, t1

li a0, 0
li t0, 1

trigger:
	add a0, a0, t0

li a7, 93
ecall