global asc_runtime_exit
section .text

asc_runtime_exit:
    mov rax, 60
    syscall
