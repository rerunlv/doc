.text

# Test 8: `pending` is set on trigger, readable in the handler, and read-only.
#
# Exit codes:
#   42 = PASS (all pending checks passed, admitted execution ran once)
#    0 = anticipation never fired (add ran with t0=0; mechanism broken upstream)
#    1 = handler entered, but pending bit not set in APCTRL
#    2 = csrci cleared pending (pending is writable via clear-bits -- FAIL)
#    3 = full csrw overwrote pending (pending is writable via write -- FAIL)

.equ mach_active, 		0x80000001		# M privilege bit | active (bit 0)
.equ pending_mask,		0x00000002		# pending is bit 1 of APCTRL (read-only)
.equ mach_act_sem, 		0x80000005		# M | APS (bit 2) | active -- admit one execution

target:									# Handler Address
	# --- Check 1: pending should read as 1 ---
	csrr t0, apctrl
	andi t1, t0, pending_mask
	beqz t1, fail_not_set

	# --- Check 2: attempt to clear pending with a clear-bits op ---
	csrci apctrl, pending_mask			# csrrc zero, apctrl, 2
	csrr t0, apctrl
	andi t1, t0, pending_mask
	beqz t1, fail_csrc_cleared			# pending must survive the clear

	# --- Check 3: attempt to overwrite pending with a full write ---
	li t1, mach_active					# value with pending bit = 0
	csrw apctrl, t1
	csrr t0, apctrl
	andi t1, t0, pending_mask
	beqz t1, fail_csrw_cleared			# pending must survive the overwrite

	# --- All checks passed: mark success, admit one execution, return ---
	li t1, mach_act_sem
	csrw apctrl, t1
	li t0, 42							# pass marker; admitted add produces a0=42
	apret zero, 0

fail_not_set:
	li a0, 1
	li a7, 93
	ecall

fail_csrc_cleared:
	li a0, 2
	li a7, 93
	ecall

fail_csrw_cleared:
	li a0, 3
	li a7, 93
	ecall

.global _start
_start:

csrwi apstatus, 1
csrwi apselect, 0

la t1, target
csrw aptar, t1

la t1, trigger
csrw aptrig, t1

li t1, mach_active
csrw apctrl, t1

li a0, 0
li t0, 0								# if anticipation never fires, a0 stays 0

trigger:
	add a0, a0, t0						# admitted execution: a0 = 0 + 42

li a7, 93
ecall
