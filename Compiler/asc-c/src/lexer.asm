global asc_lexer

section .text

asc_lexer:
    mov r12, rsi
    mov r13, rdx
    lea r14, [token_buffer]
    xor r15, r15
    xor rcx, rcx

scan:
    cmp rcx, r13
    jae finished

    mov al, [r12 + rcx]

    cmp al, ' '
    je advance

    cmp al, 9
    je advance

    cmp al, 10
    je advance

    cmp al, 13
    je advance

    call is_identifier_start
    test al, al
    jnz identifier

    mov al, [r12 + rcx]

    cmp al, '0'
    jb operators

    cmp al, '9'
    jbe integer

    jmp operators

identifier:
    mov rbx, rcx

identifier_loop:
    cmp rcx, r13
    jae identifier_end

    mov al, [r12 + rcx]
    call is_identifier_character

    test al, al
    jz identifier_end

    inc rcx
    jmp identifier_loop

identifier_end:
    push rcx

    lea rsi, [r12 + rbx]
    mov rdx, rcx
    sub rdx, rbx

    call identify_keyword

    pop rcx

    mov dword [r14], eax
    mov qword [r14 + 8], rsi
    mov qword [r14 + 16], rdx

    add r14, 24
    inc r15

    jmp scan

integer:
    xor r8, r8

integer_loop:
    cmp rcx, r13
    jae integer_end

    mov al, [r12 + rcx]

    cmp al, '0'
    jb integer_end

    cmp al, '9'
    ja integer_end

    sub al, '0'
    movzx rax, al

    imul r8, r8, 10
    add r8, rax

    inc rcx
    jmp integer_loop

integer_end:
    mov dword [r14], TOKEN_INTEGER
    mov qword [r14 + 8], r8

    add r14, 24
    inc r15

    jmp scan

operators:
    mov al, [r12 + rcx]

    cmp al, ':'
    je colon

    cmp al, '='
    je equals

    cmp al, '+'
    je plus

    cmp al, '-'
    je minus

    cmp al, '*'
    je multiply

    cmp al, '/'
    je divide

    cmp al, '('
    je left_parenthesis

    cmp al, ')'
    je right_parenthesis

    cmp al, '{'
    je left_brace

    cmp al, '}'
    je right_brace

    cmp al, '['
    je left_bracket

    cmp al, ']'
    je right_bracket

    cmp al, ','
    je comma

    cmp al, '.'
    je dot

    jmp advance

colon:
    mov dword [r14], TOKEN_COLON
    jmp simple_token

equals:
    mov dword [r14], TOKEN_EQUALS
    jmp simple_token

plus:
    mov dword [r14], TOKEN_PLUS
    jmp simple_token

minus:
    mov dword [r14], TOKEN_MINUS
    jmp simple_token

multiply:
    mov dword [r14], TOKEN_MULTIPLY
    jmp simple_token

divide:
    mov dword [r14], TOKEN_DIVIDE
    jmp simple_token

left_parenthesis:
    mov dword [r14], TOKEN_LEFT_PARENTHESIS
    jmp simple_token

right_parenthesis:
    mov dword [r14], TOKEN_RIGHT_PARENTHESIS
    jmp simple_token

left_brace:
    mov dword [r14], TOKEN_LEFT_BRACE
    jmp simple_token

right_brace:
    mov dword [r14], TOKEN_RIGHT_BRACE
    jmp simple_token

left_bracket:
    mov dword [r14], TOKEN_LEFT_BRACKET
    jmp simple_token

right_bracket:
    mov dword [r14], TOKEN_RIGHT_BRACKET
    jmp simple_token

comma:
    mov dword [r14], TOKEN_COMMA
    jmp simple_token

dot:
    mov dword [r14], TOKEN_DOT

simple_token:
    add r14, 24
    inc r15
    inc rcx
    jmp scan

advance:
    inc rcx
    jmp scan

finished:
    mov rdi, token_buffer
    mov rax, r15
    ret

is_identifier_start:
    cmp al, '_'
    je identifier_yes

    cmp al, 'A'
    jb identifier_no

    cmp al, 'Z'
    jbe identifier_yes

    cmp al, 'a'
    jb identifier_no

    cmp al, 'z'
    jbe identifier_yes

identifier_no:
    xor al, al
    ret

identifier_yes:
    mov al, 1
    ret

is_identifier_character:
    cmp al, '_'
    je character_yes

    cmp al, '0'
    jb check_upper

    cmp al, '9'
    jbe character_yes

check_upper:
    cmp al, 'A'
    jb check_lower

    cmp al, 'Z'
    jbe character_yes

check_lower:
    cmp al, 'a'
    jb character_no

    cmp al, 'z'
    jbe character_yes

character_no:
    xor al, al
    ret

character_yes:
    mov al, 1
    ret

identify_keyword:
    cmp rdx, 3
    jne check_while

    cmp byte [rsi], 'v'
    jne check_let

    cmp byte [rsi + 1], 'a'
    jne check_let

    cmp byte [rsi + 2], 'r'
    jne check_let

    mov eax, TOKEN_VAR
    ret

check_let:
    cmp byte [rsi], 'l'
    jne identifier_token

    cmp byte [rsi + 1], 'e'
    jne identifier_token

    cmp byte [rsi + 2], 't'
    jne identifier_token

    mov eax, TOKEN_LET
    ret

check_while:
    cmp rdx, 5
    jne identifier_token

    cmp byte [rsi], 'w'
    jne identifier_token

    cmp byte [rsi + 1], 'h'
    jne identifier_token

    cmp byte [rsi + 2], 'i'
    jne identifier_token

    cmp byte [rsi + 3], 'l'
    jne identifier_token

    cmp byte [rsi + 4], 'e'
    jne identifier_token

    mov eax, TOKEN_WHILE
    ret

identifier_token:
    mov eax, TOKEN_IDENTIFIER
    ret

%define TOKEN_IDENTIFIER          1
%define TOKEN_INTEGER             2
%define TOKEN_VAR                 3
%define TOKEN_LET                 4
%define TOKEN_WHILE               5
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

section .bss

token_buffer:
    resb 24576