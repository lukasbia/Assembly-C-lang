global _start

extern asc_runtime_exit

section .text
_start:
    xor rdi, rdi
    call asc_runtime_exit
