.global _start

.section .data
hello_msg:
    .string "This is a machine-level interrupt\n"
msg_len = . - hello_msg

.text

# Test 31: A standard M-mode interrupt arriving while in the
# anticipation handler: does it preempt the handler, and does
# `mret` from *that* handler return correctly with anticipation
# state intact? [ISA mod note: trap-handler code can now cross
# a live trigger and fire an AP from inside the trap handler —
# decide whether trap handlers must clear APIE on entry as a
# software convention.]

# Test 30: Anticipation versus ECALL
#
# ECALL is trigger
#
# Exit codes:
#   0 = Pass preemption occurred before ECALL
#   1 = Fail ECALL executed before preemption

.equ mach_active, 0x80000001
.equ aps_mask,    0x00000004

.global _start

target:
    # Set up and call a machine-level interrupt.
	li a0, 1                # a0 = file descriptor (1 for stdout)
    la a1, hello_msg        # a1 = address of the string to print
    li a2, msg_len          # a2 = length of the string
    li a7, 64               # a7 = syscall number for write()
    ecall                   # Make the system call
    
	li a0, 0                # a0 = exit status (0 for success)
    li a7, 93               # a7 = syscall number for exit()
    
	apret

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
	
.section .text
_start:
    # --- Print the "Hello, World!" string ---
    # The write() syscall is number 64 on RISC-V
    # ssize_t write(int fd, const void *buf, size_t count);
    # Arguments are passed in registers a0, a1, a2

    li a0, 1                # a0 = file descriptor (1 for stdout)
    la a1, hello_msg        # a1 = address of the string to print
    li a2, msg_len          # a2 = length of the string
    li a7, 64               # a7 = syscall number for write()
    ecall                   # Make the system call

    # --- Exit the program ---
    # The exit() syscall is number 93
    # void exit(int status);

    li a0, 0                # a0 = exit status (0 for success)
    li a7, 93               # a7 = syscall number for exit()
    ecall                   # Make the system call