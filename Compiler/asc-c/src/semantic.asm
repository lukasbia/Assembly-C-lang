bits 64

global asc_semantic

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
%define NODE_ASSIGN        11
%define NODE_CALL          12
%define NODE_IDENTIFIER    13
%define NODE_INTEGER       14
%define NODE_STRING        15
%define NODE_CHARACTER     16
%define NODE_BOOLEAN       17
%define NODE_NIL           18
%define NODE_MEMBER        19
%define NODE_ARRAY         20
%define NODE_BREAK         21
%define NODE_CONTINUE      22

section .text

asc_semantic:

    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13

    mov r12, rdi
    xor r13d, r13d

    call check_program

    test eax, eax
    jz .fail

    mov eax, 1

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


check_program:

    mov r8, [r12 + 16]

.loop:

    test r8, r8
    jz .ok

    mov rdi, r8
    call check_node

    test eax, eax
    jz .fail

    mov r8, [r8 + 24]
    jmp .loop

.ok:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


check_node:

    mov eax, [rdi]

    cmp eax, NODE_VAR
    je check_variable

    cmp eax, NODE_FUNCTION
    je check_function

    cmp eax, NODE_BLOCK
    je check_block

    cmp eax, NODE_RETURN
    je check_return

    cmp eax, NODE_IF
    je check_if

    cmp eax, NODE_WHILE
    je check_while

    cmp eax, NODE_BINARY
    je check_binary

    cmp eax, NODE_ASSIGN
    je check_assignment

    cmp eax, NODE_CALL
    je check_call

    cmp eax, NODE_BREAK
    je check_break

    cmp eax, NODE_CONTINUE
    je check_continue

    mov eax, 1
    ret


check_variable:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    mov r8, [rdi + 24]

    test r8, r8
    jz .ok

    mov rdi, r8
    call check_expression

    ret

.ok:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


check_function:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    mov r8, [rdi + 16]

.parameters:

    test r8, r8
    jz .body

    mov r9, [r8 + 8]

    test r9, r9
    jz .fail

    mov r8, [r8 + 24]
    jmp .parameters

.body:

    mov r8, [rdi + 40]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_node

    ret

.fail:
    xor eax, eax
    ret


check_block:

    mov r8, [rdi + 16]

.loop:

    test r8, r8
    jz .ok

    mov rdi, r8
    call check_node

    test eax, eax
    jz .fail

    mov r8, [r8 + 24]
    jmp .loop

.ok:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


check_return:

    mov r8, [rdi + 8]

    test r8, r8
    jz .ok

    mov rdi, r8
    call check_expression

    ret

.ok:
    mov eax, 1
    ret


check_if:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_expression

    test eax, eax
    jz .fail

    mov r8, [rdi + 16]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_node

    ret

.fail:
    xor eax, eax
    ret


check_while:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_expression

    test eax, eax
    jz .fail

    mov r8, [rdi + 16]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_node

    ret

.fail:
    xor eax, eax
    ret


check_binary:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_expression

    test eax, eax
    jz .fail

    mov r8, [rdi + 16]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_expression

    ret

.fail:
    xor eax, eax
    ret


check_assignment:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    cmp dword [r8], NODE_IDENTIFIER
    jne .fail

    mov r8, [rdi + 16]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_expression

    ret

.fail:
    xor eax, eax
    ret


check_call:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    cmp dword [r8], NODE_IDENTIFIER
    je .arguments

    cmp dword [r8], NODE_MEMBER
    jne .fail

.arguments:

    mov r8, [rdi + 16]

.loop:

    test r8, r8
    jz .ok

    mov rdi, r8
    call check_expression

    test eax, eax
    jz .fail

    mov r8, [r8 + 24]
    jmp .loop

.ok:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


check_expression:

    mov eax, [rdi]

    cmp eax, NODE_IDENTIFIER
    je .ok

    cmp eax, NODE_INTEGER
    je .ok

    cmp eax, NODE_STRING
    je .ok

    cmp eax, NODE_CHARACTER
    je .ok

    cmp eax, NODE_BOOLEAN
    je .ok

    cmp eax, NODE_NIL
    je .ok

    cmp eax, NODE_BINARY
    je check_binary

    cmp eax, NODE_UNARY
    je .unary

    cmp eax, NODE_CALL
    je check_call

    cmp eax, NODE_MEMBER
    je .member

    cmp eax, NODE_ARRAY
    je .array

    xor eax, eax
    ret

.unary:

    mov r8, [rdi + 8]

    test r8, r8
    jz .fail

    mov rdi, r8
    call check_expression
    ret

.member:

    mov r8, [rdi + 8]
    mov r9, [rdi + 16]

    test r8, r8
    jz .fail

    test r9, r9
    jz .fail

    mov eax, 1
    ret

.array:

    mov r8, [rdi + 16]

.array_loop:

    test r8, r8
    jz .ok

    mov rdi, r8
    call check_expression

    test eax, eax
    jz .fail

    mov r8, [r8 + 24]
    jmp .array_loop

.ok:
    mov eax, 1
    ret

.fail:
    xor eax, eax
    ret


check_break:
    mov eax, 1
    ret

check_continue:
    mov eax, 1
    ret