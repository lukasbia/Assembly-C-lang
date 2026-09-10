bits 64

global asc_semantic

%define AST_PROGRAM       1
%define AST_VARIABLE      2
%define AST_CONSTANT      3
%define AST_ASSIGNMENT    4
%define AST_INTEGER       5
%define AST_IDENTIFIER    6
%define AST_BINARY        7
%define AST_WHILE         8

%define TOKEN_PLUS        8
%define TOKEN_MINUS       9
%define TOKEN_MULTIPLY    10
%define TOKEN_DIVIDE      11

%define TYPE_INTEGER      1
%define TYPE_STRING       2
%define TYPE_BOOLEAN      3

%define SYMBOL_VARIABLE   1
%define SYMBOL_CONSTANT   2

%define SEMANTIC_OK       0
%define SEMANTIC_ERROR    1

section .text

asc_semantic:

    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    xor r14, r14
    xor r15, r15

    lea rbx, [symbol_table]

    call analyze_program

    mov rax, SEMANTIC_OK

    cmp r15, 0
    jne semantic_failed

    jmp semantic_finished

semantic_failed:

    mov rax, SEMANTIC_ERROR

semantic_finished:

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp

    ret


analyze_program:

    xor r14, r14

program_loop:

    cmp r14, r13
    jae program_finished

    mov rax, [r12 + r14 * 32]

    cmp rax, AST_VARIABLE
    je analyze_variable

    cmp rax, AST_CONSTANT
    je analyze_constant

    cmp rax, AST_ASSIGNMENT
    je analyze_assignment

    cmp rax, AST_WHILE
    je analyze_while

    inc r14
    jmp program_loop

program_finished:

    ret


analyze_variable:

    mov r8, [r12 + r14 * 32 + 8]

    call find_symbol

    test rax, rax
    jnz semantic_error

    mov r8, [r12 + r14 * 32 + 8]
    mov r9, [r12 + r14 * 32 + 16]

    call add_variable

    mov r10, [r12 + r14 * 32 + 24]

    test r10, r10
    jz variable_finished

    mov rdi, r10

    call analyze_expression

    cmp rax, TYPE_INTEGER
    jne semantic_error

variable_finished:

    inc r14
    jmp program_loop


analyze_constant:

    mov r8, [r12 + r14 * 32 + 8]

    call find_symbol

    test rax, rax
    jnz semantic_error

    mov r8, [r12 + r14 * 32 + 8]
    mov r9, [r12 + r14 * 32 + 16]

    call add_constant

    mov r10, [r12 + r14 * 32 + 24]

    test r10, r10
    jz constant_finished

    mov rdi, r10

    call analyze_expression

    cmp rax, TYPE_INTEGER
    jne semantic_error

constant_finished:

    inc r14
    jmp program_loop


analyze_assignment:

    mov r8, [r12 + r14 * 32 + 8]

    call find_symbol

    test rax, rax
    jz semantic_error

    cmp dword [rax + 16], SYMBOL_VARIABLE
    jne semantic_error

    mov r10, [r12 + r14 * 32 + 16]

    test r10, r10
    jz semantic_error

    mov rdi, r10

    call analyze_expression

    cmp rax, TYPE_INTEGER
    jne semantic_error

    inc r14
    jmp program_loop


analyze_while:

    mov r8, [r12 + r14 * 32 + 8]

    test r8, r8
    jz semantic_error

    mov rdi, r8

    call analyze_expression

    cmp rax, TYPE_BOOLEAN
    je while_condition_valid

    cmp rax, TYPE_INTEGER
    jne semantic_error

while_condition_valid:

    inc r14
    jmp program_loop


analyze_expression:

    test rdi, rdi
    jz expression_error

    mov eax, [rdi]

    cmp eax, AST_INTEGER
    je expression_integer

    cmp eax, AST_IDENTIFIER
    je expression_identifier

    cmp eax, AST_BINARY
    je expression_binary

    jmp expression_error


expression_integer:

    mov eax, TYPE_INTEGER
    ret


expression_identifier:

    mov r8, [rdi + 8]

    call find_symbol

    test rax, rax
    jz expression_error

    mov eax, TYPE_INTEGER
    ret


expression_binary:

    mov r8, [rdi + 16]
    mov r9, [rdi + 24]

    test r8, r8
    jz expression_error

    test r9, r9
    jz expression_error

    mov rdi, r8
    call analyze_expression

    cmp rax, TYPE_INTEGER
    jne expression_error

    mov rdi, r9
    call analyze_expression

    cmp rax, TYPE_INTEGER
    jne expression_error

    mov eax, TYPE_INTEGER
    ret


expression_error:

    mov eax, -1
    ret


find_symbol:

    xor rcx, rcx

find_symbol_loop:

    cmp rcx, [symbol_count]
    jae symbol_not_found

    mov rax, rcx
    imul rax, 32

    lea rdx, [symbol_table + rax]

    mov rax, [rdx]

    cmp rax, r8
    je symbol_found

    inc rcx
    jmp find_symbol_loop

symbol_found:

    mov rax, rdx
    ret

symbol_not_found:

    xor rax, rax
    ret


add_variable:

    mov rax, [symbol_count]
    imul rax, 32

    lea rdx, [symbol_table + rax]

    mov [rdx], r8
    mov dword [rdx + 16], SYMBOL_VARIABLE
    mov dword [rdx + 20], TYPE_INTEGER

    inc qword [symbol_count]

    ret


add_constant:

    mov rax, [symbol_count]
    imul rax, 32

    lea rdx, [symbol_table + rax]

    mov [rdx], r8
    mov dword [rdx + 16], SYMBOL_CONSTANT
    mov dword [rdx + 20], TYPE_INTEGER

    inc qword [symbol_count]

    ret


semantic_error:

    mov r15, 1

    ret


section .bss

symbol_count:
    resq 1

symbol_table:
    resb 32768