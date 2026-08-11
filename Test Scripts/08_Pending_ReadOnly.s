.text

# Test 8 (rev 2): `pending` semantics per clarified spec -- pending is set when
# this AP's trigger address is executed while inside its own handler (APIE=0).
# It must NOT be set on a clean take, must be readable in the handler, and must
# be read-only.
#
# Method: on clean entry, the handler verifies pending==0, sets a probe flag
# (t2), and jumps to the trigger address. With APIE=0 the instruction there
# must execute WITHOUT re-preemption, and pending must latch. The instruction
# after `trigger` routes probe-mode execution back into the handler, where the
# read-only checks run.
#
# Exit codes (0 = PASS):
#    0 = PASS
#    9 = anticipation never fired (fell through trigger in normal mode)
#    1 = pending already set on clean handler entry (should be 0)
#    2 = re-preempted while APIE=0 (nested entry -- must not happen)
#    3 = trigger addr executed under APIE=0, but pending did not set
#    4 = csrci cleared pending (writable via clear-bits -- FAIL)
#    5 = full csrw overwrote pending (writable via write -- FAIL)

.equ mach_active, 		0x80000001		# M privilege bit | active (bit 0)
.equ pending_mask,		0x00000002		# pending is bit 1 of APCTRL (read-only)
.equ mach_act_sem, 		0x80000005		# M | APS (bit 2) | active -- admit one execution

target:									# Handler Address
	bnez t2, fail_nested				# entered again while probing => preempted with APIE=0

	# --- Check 0: clean take must NOT have pending set ---
	csrr t0, apctrl
	andi t1, t0, pending_mask
	bnez t1, fail_set_on_entry

	# --- Probe: execute trigger address while APIE=0 ---
	li t2, 1							# probe mode: routes trigger fall-through back here
	j trigger

back_in_handler:
	# --- Check 1: pending should have latched during the probe ---
	csrr t0, apctrl
	andi t1, t0, pending_mask
	beqz t1, fail_not_set

	# --- Check 2: clear-bits op must not clear pending ---
	csrci apctrl, pending_mask			# csrrc zero, apctrl, 2
	csrr t0, apctrl
	andi t1, t0, pending_mask
	beqz t1, fail_csrc_cleared

	# --- Check 3: full overwrite must not clear pending ---
	li t1, mach_active					# value with pending bit = 0
	csrw apctrl, t1
	csrr t0, apctrl
	andi t1, t0, pending_mask
	beqz t1, fail_csrw_cleared

	# --- PASS: admit one execution, restore probe flag, return ---
	li t1, mach_act_sem
	csrw apctrl, t1
	li t2, 0							# leave probe mode so return path exits normally
	li a0, 0							# PASS (t0 is 0, so the admitted add keeps a0 = 0)
	apret zero, 0

fail_set_on_entry:
	li a0, 1
	li a7, 93
	ecall

fail_nested:
	li a0, 2
	li a7, 93
	ecall

fail_not_set:
	li a0, 3
	li a7, 93
	ecall

fail_csrc_cleared:
	li a0, 4
	li a7, 93
	ecall

fail_csrw_cleared:
	li a0, 5
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

li t1, mach_active						# arm active only after trig/tar are set
csrw apctrl, t1

li a0, 9								# sentinel: if anticipation never fires, exit 9
li t0, 0								# add operand stays 0 for the whole test
li t2, 0								# 0 = normal mode, 1 = handler probe mode

trigger:
	add a0, a0, t0						# probe: executes under APIE=0 / admitted: no-op

	bnez t2, back_in_handler			# probe mode returns into the handler

li a7, 93
ecall									# normal mode: exit with a0 (0 = PASS, 9 = never fired)
