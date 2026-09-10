bits 64

global asc_emit

section .text

asc_emit:

    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    mov r14, r12
    xor r15, r15

find_length:

    cmp r15, r13
    jae length_done

    inc r15
    jmp find_length

length_done:

    mov rax, 1
    mov rdi, 1
    mov rsi, r14
    mov rdx, r15

    syscall

    mov rax, r15

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp

    ret