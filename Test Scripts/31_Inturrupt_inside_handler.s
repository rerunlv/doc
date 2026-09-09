.global _start

.section .data
hello_msg:
    .string "This is a machine-level interrupt\n"
msg_len = . - hello_msg

.text

# Test 31: A standard M-mode interrupt arriving while in the
# anticipation handler: does it preempt the handler, and does
# `mret` from *that* handler return correctly with anticipation
# state intact?
#
# In Gem5 SE mode, syscall 64 (write) is used to simulate the trap /
# interrupt entry and return.
#
# Exit codes:
#   0 = Pass: preemption occurred before trigger and interrupt trap returned cleanly
#   1 = Fail: trigger ECALL executed before preemption

.equ mach_active, 0x80000001
.equ aps_mask,    0x00000004

target:
    # Set up and call simulated interrupt via write() syscall.
    li a0, 1                # a0 = file descriptor (1 for stdout)
    la a1, hello_msg        # a1 = address of the string to print
    li a2, msg_len          # a2 = length of the string
    li a7, 64               # a7 = syscall number for write()
    ecall                   # Make the system call

    # Successfully returned from simulated interrupt; exit with 0
    li a0, 0                # a0 = exit status (0 for success)
    li a7, 93               # a7 = syscall number for exit()
    ecall

_start:
    csrwi apselect, 0

    la t0, target
    csrw aptar, t0

    la t0, trigger_ecall
    csrw aptrig, t0

    li t0, mach_active
    csrw apctrl, t0

    li t0, 1
    csrw apstatus, t0

    # Fail, ECALL executes before preemption if a0 stays as 1
    li a0, 1
    li a7, 93

trigger_ecall:
    ecall
