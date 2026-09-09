.text

# Test 13b: apret does NOT modify APIE (Rev 2 semantics: APIE is preserved across apret)
#
# Exit codes:
#   0 = Pass: apret preserves APIE in both APIE=0 and APIE=1 states and redirects to APEPC
#   1 = Fail: apret changed APIE from 0 to 1
#   2 = Fail: apret changed APIE from 1 to 0
#   3 = Fail: apret did not redirect in phase 1 (APIE=0)
#   4 = Fail: apret did not redirect in phase 2 (APIE=1)

.global _start

_start:
    # --- Phase 1: APIE = 0 ---
    csrci apstatus, 1

    # Verify APIE is 0
    csrr t0, apstatus
    andi t0, t0, 1
    bnez t0, fail_apie_0_to_1

    la t0, phase2
    csrw apepc, t0

    apret

    # If apret did not redirect:
    li a0, 3
    li a7, 93
    ecall

phase2:
    # Check if APIE is still 0
    csrr t0, apstatus
    andi t0, t0, 1
    bnez t0, fail_apie_0_to_1

    # --- Phase 2: APIE = 1 ---
    csrsi apstatus, 1

    # Verify APIE is 1
    csrr t0, apstatus
    andi t0, t0, 1
    beqz t0, fail_apie_1_to_0

    la t0, pass_exit
    csrw apepc, t0

    apret

    # If apret did not redirect:
    li a0, 4
    li a7, 93
    ecall

pass_exit:
    # Check if APIE is still 1
    csrr t0, apstatus
    andi t0, t0, 1
    beqz t0, fail_apie_1_to_0

    # PASS
    li a0, 0
    li a7, 93
    ecall

fail_apie_0_to_1:
    li a0, 1
    li a7, 93
    ecall

fail_apie_1_to_0:
    li a0, 2
    li a7, 93
    ecall
