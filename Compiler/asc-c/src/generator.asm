bits 64

global asc_generate

%define AST_PROGRAM       1
%define AST_VARIABLE      2
%define AST_CONSTANT      3
%define AST_ASSIGNMENT    4
%define AST_INTEGER       5
%define AST_IDENTIFIER     6
%define AST_BINARY        7
%define AST_WHILE         8

%define TOKEN_PLUS        8
%define TOKEN_MINUS       9
%define TOKEN_MULTIPLY    10
%define TOKEN_DIVIDE      11

section .text

asc_generate:

    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    lea r14, [output_buffer]
    xor r15, r15
    xor rbx, rbx

    call generate_program

    mov byte [r14], 0

    lea rax, [output_buffer]
    mov rdx, r14
    sub rdx, rax

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp

    ret


generate_program:

    xor rcx, rcx

    lea rsi, [section_text]
    call emit_string

program_loop:

    cmp rcx, r13
    jae program_finished

    mov eax, [r12 + rcx * 32]

    cmp eax, AST_VARIABLE
    je generate_variable

    cmp eax, AST_CONSTANT
    je generate_constant

    cmp eax, AST_ASSIGNMENT
    je generate_assignment

    cmp eax, AST_WHILE
    je generate_while

    inc rcx
    jmp program_loop

program_finished:

    ret


generate_variable:

    mov r8, [r12 + rcx * 32 + 8]
    mov r9, [r12 + rcx * 32 + 24]

    lea rsi, [variable_prefix]
    call emit_string

    mov rsi, r8
    mov rdx, 0

    call emit_identifier

    lea rsi, [variable_suffix]
    call emit_string

    test r9, r9
    jz variable_next

    mov rdi, r9
    call generate_expression

variable_next:

    lea rsi, [newline]
    call emit_string

    inc rcx
    jmp program_loop


generate_constant:

    mov r8, [r12 + rcx * 32 + 8]
    mov r9, [r12 + rcx * 32 + 24]

    lea rsi, [constant_prefix]
    call emit_string

    mov rsi, r8
    call emit_identifier

    lea rsi, [constant_suffix]
    call emit_string

    test r9, r9
    jz constant_next

    mov rdi, r9
    call generate_expression

constant_next:

    lea rsi, [newline]
    call emit_string

    inc rcx
    jmp program_loop


generate_assignment:

    mov r8, [r12 + rcx * 32 + 8]
    mov r9, [r12 + rcx * 32 + 16]

    lea rsi, [assignment_prefix]
    call emit_string

    mov rsi, r8
    call emit_identifier

    lea rsi, [assignment_middle]
    call emit_string

    mov rdi, r9
    call generate_expression

    lea rsi, [newline]
    call emit_string

    inc rcx
    jmp program_loop


generate_expression:

    mov eax, [rdi]

    cmp eax, AST_INTEGER
    je generate_integer

    cmp eax, AST_IDENTIFIER
    je generate_identifier

    cmp eax, AST_BINARY
    je generate_binary

    ret


generate_integer:

    mov rax, [rdi + 8]

    lea rsi, [integer_prefix]
    call emit_string

    mov rsi, rax
    call emit_integer

    ret


generate_identifier:

    mov rsi, [rdi + 8]

    lea rdx, [rdi + 16]

    call emit_identifier

    ret


generate_binary:

    push rdi

    mov r8, [rdi + 16]
    mov r9, [rdi + 24]
    mov r10, [rdi + 8]

    mov rdi, r8
    call generate_expression

    lea rsi, [space]
    call emit_string

    cmp r10, TOKEN_PLUS
    je binary_plus

    cmp r10, TOKEN_MINUS
    je binary_minus

    cmp r10, TOKEN_MULTIPLY
    je binary_multiply

    cmp r10, TOKEN_DIVIDE
    je binary_divide

    pop rdi
    ret


binary_plus:

    lea rsi, [plus]
    call emit_string
    jmp binary_right


binary_minus:

    lea rsi, [minus]
    call emit_string
    jmp binary_right


binary_multiply:

    lea rsi, [multiply]
    call emit_string
    jmp binary_right


binary_divide:

    lea rsi, [divide]
    call emit_string


binary_right:

    lea rsi, [space]
    call emit_string

    mov rdi, r9
    call generate_expression

    pop rdi
    ret


generate_while:

    mov r8, [r12 + rcx * 32 + 8]

    lea rsi, [while_prefix]
    call emit_string

    mov rdi, r8
    call generate_expression

    lea rsi, [while_suffix]
    call emit_string

    inc rcx
    jmp program_loop


emit_string:

    mov al, [rsi]

    test al, al
    jz emit_string_finished

    mov [r14], al
    inc r14
    inc rsi

    jmp emit_string

emit_string_finished:

    ret


emit_identifier:

    mov al, [rsi]

    test al, al
    jz emit_identifier_finished

    cmp al, ' '
    je emit_identifier_finished

    cmp al, 10
    je emit_identifier_finished

    mov [r14], al
    inc r14
    inc rsi

    jmp emit_identifier

emit_identifier_finished:

    ret


emit_integer:

    push rax
    push rbx
    push rcx
    push rdx

    test rsi, rsi
    jnz integer_positive

    mov byte [r14], '0'
    inc r14
    jmp integer_finished


integer_positive:

    xor rcx, rcx
    mov rax, rsi
    mov rbx, 10

integer_convert:

    xor rdx, rdx
    div rbx

    add dl, '0'

    push rdx

    inc rcx

    test rax, rax
    jnz integer_convert


integer_write:

    pop rax

    mov [r14], al
    inc r14

    loop integer_write


integer_finished:

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret


section .data

section_text:
    db "section .text", 10
    db "global _start", 10
    db "_start:", 10, 0

variable_prefix:
    db "    mov qword [", 0

variable_suffix:
    db "], 0", 0

constant_prefix:
    db "    mov qword [", 0

constant_suffix:
    db "], 0", 0

assignment_prefix:
    db "    mov rax, [", 0

assignment_middle:
    db "]", 10
    db "    ", 0

while_prefix:
    db "while_", 0

while_suffix:
    db ":", 10, 0

integer_prefix:
    db "    mov rax, ", 0

space:
    db " ", 0

plus:
    db "+", 0

minus:
    db "-", 0

multiply:
    db "*", 0

divide:
    db "/", 0

newline:
    db 10, 0


section .bss

output_buffer:
    resb 1048576