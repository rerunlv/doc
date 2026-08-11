.text

# Test 13a: Apret sets PC to APEPC
#
# Exit codes:
#   0 = PASS, Apret redirects to APEPC
#   1 = FAIL, Apret did not redirect to APEPC

.global _start

_start:
    la t0, apret_path
    csrw apepc, t0

    apret

    # Fail, APRET did not redirect
    li a0, 1
    li a7, 93
    ecall

apret_path:
    # Pass
    li a0, 0
    li a7, 93
    ecall