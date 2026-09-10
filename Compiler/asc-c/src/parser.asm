bits 64

global asc_parser

extern asc_lexer

%define TOKEN_EOF                  0
%define TOKEN_IDENTIFIER           1
%define TOKEN_INTEGER              2
%define TOKEN_STRING               3

%define TOKEN_VAR                  3
%define TOKEN_LET                  4
%define TOKEN_WHILE                5

%define TOKEN_COLON               6
%define TOKEN_EQUALS              7
%define TOKEN_PLUS                8
%define TOKEN_MINUS               9
%define TOKEN_MULTIPLY            10
%define TOKEN_DIVIDE              11

%define TOKEN_LEFT_PARENTHESIS    12
%define TOKEN_RIGHT_PARENTHESIS   13
%define TOKEN_LEFT_BRACE          14
%define TOKEN_RIGHT_BRACE         15
%define TOKEN_LEFT_BRACKET        16
%define TOKEN_RIGHT_BRACKET       17
%define TOKEN_COMMA               18
%define TOKEN_DOT                 19

%define AST_PROGRAM                1
%define AST_VARIABLE               2
%define AST_CONSTANT               3
%define AST_ASSIGNMENT             4
%define AST_INTEGER                5
%define AST_IDENTIFIER             6
%define AST_BINARY                 7
%define AST_WHILE                  8

%define TYPE_INTEGER               1
%define TYPE_STRING                2
%define TYPE_BOOLEAN               3

section .text

asc_parser:

    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    call asc_lexer

    mov r12, rdx
    xor r13, r13
    lea r14, [ast_buffer]

    call parse_program

    mov rax, r14
    lea rdx, [ast_buffer]

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp

    ret


parse_program:

    mov dword [r14], AST_PROGRAM
    mov qword [r14 + 8], 0
    mov qword [r14 + 16], 0
    mov qword [r14 + 24], 0

    add r14, 32

program_loop:

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_EOF
    je program_finished

    cmp eax, TOKEN_VAR
    je parse_variable

    cmp eax, TOKEN_LET
    je parse_constant

    cmp eax, TOKEN_WHILE
    je parse_while

    cmp eax, TOKEN_IDENTIFIER
    je parse_assignment

    inc r13
    jmp program_loop

program_finished:

    ret


parse_variable:

    mov r8, r13

    inc r13

    call parse_declaration

    mov dword [r14], AST_VARIABLE
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], rax
    mov qword [r14 + 24], rdx

    add r14, 32

    jmp program_loop


parse_constant:

    mov r8, r13

    inc r13

    call parse_declaration

    mov dword [r14], AST_CONSTANT
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], rax
    mov qword [r14 + 24], rdx

    add r14, 32

    jmp program_loop


parse_declaration:

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_IDENTIFIER
    jne declaration_error

    mov r9, r13

    inc r13

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_COLON
    jne declaration_without_type

    inc r13

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_IDENTIFIER
    jne declaration_error

    mov r10, r13

    inc r13

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_EQUALS
    jne declaration_without_value

    inc r13

    call parse_expression

    mov rdx, rax
    mov rax, r9

    ret

declaration_without_type:

    xor r10, r10

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_EQUALS
    jne declaration_error

    inc r13

    call parse_expression

    mov rdx, rax
    mov rax, r9

    ret

declaration_without_value:

    mov rax, r9
    xor rdx, rdx

    ret

declaration_error:

    xor rax, rax
    xor rdx, rdx

    ret


parse_assignment:

    mov r8, r13

    inc r13

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_EQUALS
    jne assignment_error

    inc r13

    call parse_expression

    mov dword [r14], AST_ASSIGNMENT
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], rax
    mov qword [r14 + 24], 0

    add r14, 32

    jmp program_loop

assignment_error:

    inc r13
    jmp program_loop


parse_while:

    inc r13

    call parse_expression

    mov r8, rax

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_DO
    je while_do

    jmp while_finished

while_do:

    inc r13

    mov r9, r14

    mov dword [r14], AST_WHILE
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], 0
    mov qword [r14 + 24], 0

    add r14, 32

while_loop:

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_EOF
    je while_finished

    cmp eax, TOKEN_END
    je while_end

    cmp eax, TOKEN_VAR
    je while_variable

    cmp eax, TOKEN_LET
    je while_constant

    cmp eax, TOKEN_IDENTIFIER
    je while_assignment

    inc r13
    jmp while_loop

while_variable:

    mov r8, r13

    inc r13

    call parse_declaration

    mov dword [r14], AST_VARIABLE
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], rax
    mov qword [r14 + 24], rdx

    add r14, 32

    jmp while_loop

while_constant:

    mov r8, r13

    inc r13

    call parse_declaration

    mov dword [r14], AST_CONSTANT
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], rax
    mov qword [r14 + 24], rdx

    add r14, 32

    jmp while_loop

while_assignment:

    mov r8, r13

    inc r13

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_EQUALS
    jne while_loop

    inc r13

    call parse_expression

    mov dword [r14], AST_ASSIGNMENT
    mov qword [r14 + 8], r8
    mov qword [r14 + 16], rax
    mov qword [r14 + 24], 0

    add r14, 32

    jmp while_loop

while_end:

    inc r13

while_finished:

    ret


parse_expression:

    call parse_primary

    mov r8, rax

expression_loop:

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_PLUS
    je expression_plus

    cmp eax, TOKEN_MINUS
    je expression_minus

    cmp eax, TOKEN_MULTIPLY
    je expression_multiply

    cmp eax, TOKEN_DIVIDE
    je expression_divide

    mov rax, r8
    ret

expression_plus:

    mov r9, TOKEN_PLUS
    jmp binary_expression

expression_minus:

    mov r9, TOKEN_MINUS
    jmp binary_expression

expression_multiply:

    mov r9, TOKEN_MULTIPLY
    jmp binary_expression

expression_divide:

    mov r9, TOKEN_DIVIDE

binary_expression:

    inc r13

    push r9
    push r8

    call parse_primary

    mov r10, rax

    pop r8
    pop r9

    mov dword [r14], AST_BINARY
    mov qword [r14 + 8], r9
    mov qword [r14 + 16], r8
    mov qword [r14 + 24], r10

    mov r8, r14

    add r14, 32

    jmp expression_loop


parse_primary:

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_INTEGER
    je primary_integer

    cmp eax, TOKEN_IDENTIFIER
    je primary_identifier

    cmp eax, TOKEN_LEFT_PARENTHESIS
    je primary_parenthesis

    xor rax, rax
    ret


primary_integer:

    mov rax, [r12 + r13 * 24 + 8]

    mov dword [r14], AST_INTEGER
    mov qword [r14 + 8], rax
    mov qword [r14 + 16], 0
    mov qword [r14 + 24], 0

    mov rax, r14

    add r14, 32
    inc r13

    ret


primary_identifier:

    mov rax, [r12 + r13 * 24 + 8]

    mov dword [r14], AST_IDENTIFIER
    mov qword [r14 + 8], rax
    mov qword [r14 + 16], [r12 + r13 * 24 + 16]
    mov qword [r14 + 24], 0

    mov rax, r14

    add r14, 32
    inc r13

    ret


primary_parenthesis:

    inc r13

    call parse_expression

    mov r8, rax

    mov eax, [r12 + r13 * 24]

    cmp eax, TOKEN_RIGHT_PARENTHESIS
    jne parenthesis_finished

    inc r13

parenthesis_finished:

    mov rax, r8
    ret


section .bss

ast_buffer:
    resb 1048576