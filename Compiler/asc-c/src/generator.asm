bits 64

global asc_generate

extern malloc

%define NODE_PROGRAM       1
%define NODE_BLOCK         2
%define NODE_VAR           3
%define NODE_FUNCTION      4
%define NODE_PARAMETER     5
%define NODE_RETURN        6
%define NODE_IF            7
%define NODE_WHILE         8
%define NODE_BINARY        9
%define NODE_UNARY         10
%define NODE_CALL          12
%define NODE_IDENTIFIER    13
%define NODE_INTEGER       14

%define IR_SIZE            32
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

section .text

asc_generate:

    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13

    mov r12, rdi

    mov edi, 32
    call malloc

    test rax, rax
    jz .fail

    mov r13, rax

    mov dword [rax], IR_PROGRAM
    mov qword [rax + 8], 0
    mov qword [rax + 16], 0
    mov qword [rax + 24], 0

    mov r8, [r12 + 16]

.loop:

    test r8, r8
    jz .done

    mov rdi, r8
    mov rsi, r13

    call generate_node

    test eax, eax
    jz .fail

    mov r8, [r8 + 24]
    jmp .loop

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


generate_node:

    mov eax, [rdi]

    cmp eax, NODE_FUNCTION
    je generate_function

    cmp eax, NODE_VAR
    je generate_variable

    cmp eax, NODE_RETURN
    je generate_return

    cmp eax, NODE_BLOCK
    je generate_block

    cmp eax, NODE_IF
    je generate_if

    cmp eax, NODE_WHILE
    je generate_while

    mov eax, 1
    ret


generate_function:

    mov eax, 1
    ret


generate_variable:

    mov r8, [rdi + 24]

    test r8, r8
    jz .done

    mov rdi, r8
    call generate_expression

.done:
    mov eax, 1
    ret


generate_return:

    mov r8, [rdi + 8]

    test r8, r8
    jz .empty

    mov rdi, r8
    call generate_expression

.empty:
    mov eax, 1
    ret


generate_block:

    mov r8, [rdi + 16]

.loop:

    test r8, r8
    jz .done

    mov rdi, r8
    call generate_node

    test eax, eax
    jz .fail

    mov r8, [r8 + 24]
    jmp .loop

.done:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


generate_if:

    mov r8, [rdi + 8]
    mov r9, [rdi + 16]

    test r8, r8
    jz .fail

    test r9, r9
    jz .fail

    mov rdi, r8
    call generate_expression

    mov rdi, r9
    call generate_node

    mov r8, [rdi + 24]

    test r8, r8
    jz .done

    mov rdi, r8
    call generate_node

.done:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


generate_while:

    mov r8, [rdi + 8]
    mov r9, [rdi + 16]

    test r8, r8
    jz .fail

    test r9, r9
    jz .fail

    mov rdi, r8
    call generate_expression

    mov rdi, r9
    call generate_node

    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


generate_expression:

    mov eax, [rdi]

    cmp eax, NODE_INTEGER
    je .integer

    cmp eax, NODE_IDENTIFIER
    je .identifier

    cmp eax, NODE_BINARY
    je .binary

    cmp eax, NODE_CALL
    je .call

    mov eax, 1
    ret

.integer:

    mov eax, IR_LOAD_IMM
    ret

.identifier:

    mov eax, IR_LOAD
    ret

.binary:

    mov r8, [rdi + 8]
    mov r9, [rdi + 16]

    test r8, r8
    jz .fail

    test r9, r9
    jz .fail

    mov rdi, r8
    call generate_expression

    mov rdi, r9
    call generate_expression

    mov eax, IR_ADD
    ret

.call:

    mov eax, IR_CALL
    ret

.fail:
    xor eax, eax
    ret