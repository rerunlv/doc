.text

# Test 13b: Apret sets APIE set to 1
#
# Exit codes:
#   0 = PASS, Apret redirects to APEPC
#   1 = Fail, APIE set to 0
#   2 = Fail, Apret did not redirect to APEPC

.global _start

_start:
    # Clear APIE
    csrwi apstatus, 0

    la t0, apret_path
    csrw apepc, t0

    apret

# Fail, apret does not redirect to APEPC
    li a0, 2
    li a7, 93
    ecall

apret_path:
    csrr t0, apstatus
    beqz t0, fail

# Pass, APIE set to 1 
    li a0, 0
    li a7, 93
    ecall

fail:
# Fail, apret does not set APIE to 0
    li a0, 1
    li a7, 93
    ecall