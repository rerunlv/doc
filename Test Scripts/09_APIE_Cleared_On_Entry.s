.text

# Test 9: APIE (APSTATUS bit 0) is cleared on handler entry -- no nested
# anticipation while inside the handler. Also checks (bonus, from item 13)
# that apret restores APIE on return.
#
# Exit codes:
#   42 = PASS (APIE clear inside handler, restored after apret)
#    0 = anticipation never fired (add ran with t0=0; mechanism broken upstream)
#    1 = APIE still set inside the handler (entry did not clear it -- FAIL)
#    2 = APIE not restored after apret (return did not set it -- FAIL)

.equ mach_active, 		0x80000001		# M privilege bit | active (bit 0)
.equ apie_mask,			0x00000001		# APIE is bit 0 of APSTATUS
.equ mach_act_sem, 		0x80000005		# M | APS (bit 2) | active -- admit one execution

target:									# Handler Address
	# --- Check 1: APIE must have been cleared by handler entry ---
	csrr t0, apstatus
	andi t1, t0, apie_mask
	bnez t1, fail_apie_set

	# --- Passed: mark success, admit one execution, return ---
	li t1, mach_act_sem
	csrw apctrl, t1
	li t0, 42							# pass marker; admitted add produces a0=42
	apret zero, 0

fail_apie_set:
	li a0, 1
	li a7, 93
	ecall

.global _start
_start:

csrwi apstatus, 1
csrwi apselect, 0
li t1, mach_active
csrw apctrl, t1
la t1, target
csrw aptar, t1

la t1, trigger
csrw aptrig, t1

li a0, 0
li t0, 0								# if anticipation never fires, a0 stays 0

trigger:
	add a0, a0, t0						# admitted execution: a0 = 0 + 42

# --- Check 2 (bonus): apret should have restored APIE = 1 ---
	csrr t1, apstatus
	andi t1, t1, apie_mask
	beqz t1, fail_apie_not_restored

	li a7, 93
	ecall								# exit 42 = PASS

fail_apie_not_restored:
	li a0, 2
	li a7, 93
	ecall
