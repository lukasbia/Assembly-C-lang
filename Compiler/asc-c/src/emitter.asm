bits 64

global asc_emit

extern malloc
extern memcpy

%define IR_PROGRAM         1
%define IR_FUNCTION        2
%define IR_LABEL           3
%define IR_LOAD_IMM        4
%define IR_LOAD            5
%define IR_STORE           6
%define IR_ADD             7
%define IR_SUB             8
%define IR_MUL             9
%define IR_DIV             10
%define IR_COMPARE         11
%define IR_JUMP            12
%define IR_JUMP_ZERO       13
%define IR_CALL            14
%define IR_RETURN          15

%define OUTPUT_SIZE        1048576

section .text

asc_emit:

    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13

    mov r12, rdi

    mov edi, OUTPUT_SIZE
    call malloc

    test rax, rax
    jz .fail

    mov r13, rax
    xor ebx, ebx

    mov rdi, r13
    call emit_header

.loop:

    mov eax, [r12]

    cmp eax, IR_PROGRAM
    je .program

    cmp eax, IR_FUNCTION
    je .function

    cmp eax, IR_LABEL
    je .label

    cmp eax, IR_LOAD_IMM
    je .load_imm

    cmp eax, IR_LOAD
    je .load

    cmp eax, IR_STORE
    je .store

    cmp eax, IR_ADD
    je .add

    cmp eax, IR_SUB
    je .sub

    cmp eax, IR_MUL
    je .mul

    cmp eax, IR_DIV
    je .div

    cmp eax, IR_CALL
    je .call

    cmp eax, IR_RETURN
    je .return

    jmp .done

.program:

    mov r12, [r12 + 16]
    test r12, r12
    jz .done

    jmp .loop

.function:

    mov rdi, r13
    mov rsi, function_text
    call emit_string

    mov r12, [r12 + 16]
    jmp .loop

.label:

    mov rdi, r13
    mov rsi, label_text
    call emit_string
    jmp .next

.load_imm:

    mov rdi, r13
    mov rsi, load_imm_text
    call emit_string
    jmp .next

.load:

    mov rdi, r13
    mov rsi, load_text
    call emit_string
    jmp .next

.store:

    mov rdi, r13
    mov rsi, store_text
    call emit_string
    jmp .next

.add:

    mov rdi, r13
    mov rsi, add_text
    call emit_string
    jmp .next

.sub:

    mov rdi, r13
    mov rsi, sub_text
    call emit_string
    jmp .next

.mul:

    mov rdi, r13
    mov rsi, mul_text
    call emit_string
    jmp .next

.div:

    mov rdi, r13
    mov rsi, div_text
    call emit_string
    jmp .next

.call:

    mov rdi, r13
    mov rsi, call_text
    call emit_string
    jmp .next

.return:

    mov rdi, r13
    mov rsi, return_text
    call emit_string
    jmp .next

.next:

    mov r12, [r12 + 24]
    test r12, r12
    jnz .loop

.done:

    mov rax, r13

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

.fail:

    xor eax, eax

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


emit_header:

    mov rsi, header_text
    call emit_string
    ret


emit_string:

    push rdi
    push rsi
    push rcx

    xor ecx, ecx

.find:

    cmp byte [rsi + rcx], 0
    je .copy

    inc rcx
    jmp .find

.copy:

    push rdi
    push rsi
    mov rdx, rcx
    call memcpy
    pop rsi
    pop rdi

    pop rcx
    pop rsi
    pop rdi
    ret


section .rodata

header_text:
    db "bits 64", 10
    db "default rel", 10, 10
    db "section .text", 10
    db "global main", 10
    db "main:", 10
    db "    push rbp", 10
    db "    mov rbp, rsp", 10
    db 0

function_text:
    db "    ; function", 10
    db 0

label_text:
    db "    ; label", 10
    db 0

load_imm_text:
    db "    mov rax, 0", 10
    db 0

load_text:
    db "    mov rax, [rbp-8]", 10
    db 0

store_text:
    db "    mov [rbp-8], rax", 10
    db 0

add_text:
    db "    add rax, rbx", 10
    db 0

sub_text:
    db "    sub rax, rbx", 10
    db 0

mul_text:
    db "    imul rax, rbx", 10
    db 0

div_text:
    db "    cqo", 10
    db "    idiv rbx", 10
    db 0

call_text:
    db "    call rax", 10
    db 0

return_text:
    db "    mov rsp, rbp", 10
    db "    pop rbp", 10
    db "    ret", 10
    db 0