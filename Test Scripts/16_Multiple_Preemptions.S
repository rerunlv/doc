.text

# Test 16: APS admits exactly one trigger execution
#
# Expected sequence:
#   1. First arrival at APTRIG preempts.
#   2. First handler entry sets APS.
#   3. APRET returns to APTRIG.
#   4. APS admits the trigger instruction exactly once.
#   5. Hardware clears APS.
#   6. The loop reaches APTRIG again.
#   7. The second arrival preempts.
#
# Exit codes:
#   0 = PASS
#   1 = Initial preemption occurred too late
#   2 = Trigger instruction executed more than once
#   3 = Unexpected handler-entry count
#   4 = APS was still set during second handler entry
#   5 = Software failed to set APS
#   6 = Trigger instruction never executed

.equ mach_active, 0x80000001
.equ aps_mask,    0x00000004
.equ active_mask, 0x00000001

.global _start


target:
    # Count handler entries.
    addi s1, s1, 1

    # Determine whether this is the first or second handler entry.
    li t0, 1
    beq s1, t0, first_handler_entry

    li t0, 2
    beq s1, t0, second_handler_entry

    # More than two entries is unexpected.
    j handler_count_failure


first_handler_entry:
    # The initial trigger instruction must not have executed.
    bnez s0, initial_preemption_failure

    # Set APS without changing the other APCTRL bits
    csrr t0, apctrl
    ori  t0, t0, aps_mask
    csrw apctrl, t0

    # Confirm APS was successfully set.
    csrr t0, apctrl
    andi t0, t0, aps_mask
    beqz t0, aps_set_failure

    # Return to APTRIG with APS set.
    apret


second_handler_entry:
    # APS should have admitted the trigger instruction once.
    beqz s0, trigger_never_executed

    # It must have executed exactly once.
    li t0, 1
    bne s0, t0, trigger_multiple_times_2

    # APS must have been cleared by the admitted execution.
    csrr t0, apctrl
    andi t0, t0, aps_mask
    bnez t0, aps_clear_failure

    # PASS
    li a0, 0
    li a7, 93
    ecall


_start:
    csrwi apstatus, 1
    csrwi apselect, 0

    # Trigger-instruction execution count.
    li s0, 0

    # Handler-entry count.
    li s1, 0

    # Activate lane 0.
    li t0, mach_active
    csrw apctrl, t0

    # Configure handler address.
    la t0, target
    csrw aptar, t0

    # Configure trigger address.
    la t0, trigger
    csrw aptrig, t0

    la t0, trigger
    csrw aptrig, t0

loop_entry:
    # This address is not APTRIG.
    nop

trigger:
    # APS should admit this instruction exactly once.
    addi s0, s0, 1

    # Active clear check
    csrr t1, apctrl
    andi t1, t1, active_mask
    beqz t1, active_clear_failure

    # The trigger instruction must execute exactly once.
    li t0, 1
    bne s0, t0, trigger_multiple_times

    # Jump above APTRIG, then reach it again by fall-through.
    j loop_entry

initial_preemption_failure:
    li a0, 1
    li a7, 93
    ecall


trigger_multiple_times:
    li a0, 2
    li a7, 93
    ecall

trigger_multiple_times_2:
    li a0, 7
    li a7, 93
    ecall

handler_count_failure:
    li a0, 3
    li a7, 93
    ecall


aps_clear_failure:
    li a0, 4
    li a7, 93
    ecall


aps_set_failure:
    li a0, 5
    li a7, 93
    ecall

trigger_never_executed:
    li a0, 6
    li a7, 93
    ecall

active_clear_failure:
    li a0, 11
    li a7, 93
    ecall