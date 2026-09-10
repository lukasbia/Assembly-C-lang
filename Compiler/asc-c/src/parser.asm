bits 64

global asc_parser

extern malloc

%define TOKEN_EOF          0
%define TOKEN_IDENTIFIER   1
%define TOKEN_INTEGER      2
%define TOKEN_STRING       3
%define TOKEN_CHARACTER    4
%define TOKEN_KEYWORD      5
%define TOKEN_OPERATOR     6
%define TOKEN_PUNCTUATION  7

%define TOKEN_SIZE         32
%define NODE_SIZE          128

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

%define KW_VAR             1
%define KW_LET             2
%define KW_FUNC            3
%define KW_IF              5
%define KW_ELSE            6
%define KW_WHILE           7
%define KW_RETURN          11
%define KW_BREAK           12
%define KW_CONTINUE        13
%define KW_TRUE            14
%define KW_FALSE           15
%define KW_NIL             16
%define KW_SELF            32
%define KW_SUPER           33

%define OP_PLUS             1
%define OP_MINUS            2
%define OP_MUL              3
%define OP_DIV              4
%define OP_MOD              5
%define OP_ASSIGN           6
%define OP_EQ               7
%define OP_NE               8
%define OP_LT               9
%define OP_GT               10
%define OP_LE               11
%define OP_GE               12
%define OP_AND              13
%define OP_OR               14
%define OP_NOT              15
%define OP_BITAND           16
%define OP_BITOR            17
%define OP_XOR              18
%define OP_SHL              19
%define OP_SHR              20
%define OP_INC              21
%define OP_DEC              22
%define OP_ADD_ASSIGN       27
%define OP_SUB_ASSIGN       28
%define OP_MUL_ASSIGN       29
%define OP_DIV_ASSIGN       30

%define P_OPEN              1
%define P_CLOSE             2
%define P_LBRACKET          3
%define P_RBRACKET          4
%define P_LBRACE            5
%define P_RBRACE            6
%define P_COMMA             7
%define P_COLON             8
%define P_SEMICOLON         9
%define P_DOT               10

section .text

asc_parser:

    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    xor r14d, r14d

    call parse_program

    mov rbx, rax

    mov rax, rbx
    mov rdx, r14

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


parse_program:

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_PROGRAM
    mov r15, rax

.loop:

    call token_type

    cmp eax, TOKEN_EOF
    je .done

    call parse_statement
    test rax, rax
    jz .fail

    mov r8, rax

    mov rdx, [r15 + 16]

    test rdx, rdx
    jz .first

    mov rcx, rdx

.find:

    mov r9, [rcx + 24]

    test r9, r9
    jz .append

    mov rcx, r9
    jmp .find

.append:

    mov [rcx + 24], r8
    jmp .loop

.first:

    mov [r15 + 16], r8
    jmp .loop

.done:

    mov rax, r15
    ret

.fail:
    xor eax, eax
    ret


parse_statement:

    call token_type

    cmp eax, TOKEN_KEYWORD
    jne .expression

    call token_value

    cmp eax, KW_VAR
    je parse_variable

    cmp eax, KW_LET
    je parse_variable

    cmp eax, KW_FUNC
    je parse_function

    cmp eax, KW_IF
    je parse_if

    cmp eax, KW_WHILE
    je parse_while

    cmp eax, KW_RETURN
    je parse_return

    cmp eax, KW_BREAK
    je parse_break

    cmp eax, KW_CONTINUE
    je parse_continue

.expression:

    call parse_expression
    ret


parse_variable:

    call token_value
    mov r8d, eax

    call advance

    call expect_identifier
    test rax, rax
    jz .fail

    mov r9, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_VAR
    mov dword [rax + 4], r8d
    mov [rax + 8], r9

    mov r10, rax

    call token_type
    cmp eax, TOKEN_PUNCTUATION
    jne .initializer

    call punctuation_value
    cmp eax, P_COLON
    jne .initializer

    call advance

    call expect_identifier
    test rax, rax
    jz .fail

    mov [r10 + 16], rax

.initializer:

    call token_type
    cmp eax, TOKEN_OPERATOR
    jne .finish

    call token_value
    cmp eax, OP_ASSIGN
    jne .finish

    call advance

    call parse_expression
    test rax, rax
    jz .fail

    mov [r10 + 24], rax

.finish:

    call consume_semicolon

    mov rax, r10
    ret

.fail:
    xor eax, eax
    ret


parse_function:

    call advance

    call expect_identifier
    test rax, rax
    jz .fail

    mov r8, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_FUNCTION
    mov [rax + 8], r8

    mov r9, rax

    call expect_punctuation
    cmp eax, P_OPEN
    jne .fail

    call advance

.parameters:

    call token_type

    cmp eax, TOKEN_PUNCTUATION
    jne .parameter

    call punctuation_value
    cmp eax, P_CLOSE
    je .close_parameters

.parameter:

    call expect_identifier
    test rax, rax
    jz .fail

    mov r10, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_PARAMETER
    mov [rax + 8], r10

    mov r11, rax

    call token_type
    cmp eax, TOKEN_PUNCTUATION
    jne .add_parameter

    call punctuation_value
    cmp eax, P_COLON
    jne .add_parameter

    call advance

    call expect_identifier
    test rax, rax
    jz .fail

    mov [r11 + 16], rax

.add_parameter:

    mov rdx, [r9 + 16]

    test rdx, rdx
    jz .first_parameter

    mov rcx, rdx

.find_parameter:

    mov r8, [rcx + 24]

    test r8, r8
    jz .append_parameter

    mov rcx, r8
    jmp .find_parameter

.append_parameter:

    mov [rcx + 24], r11
    jmp .next_parameter

.first_parameter:

    mov [r9 + 16], r11

.next_parameter:

    call token_type
    cmp eax, TOKEN_PUNCTUATION
    jne .parameters

    call punctuation_value
    cmp eax, P_COMMA
    jne .parameters

    call advance
    jmp .parameters

.close_parameters:

    call advance

    call token_type
    cmp eax, TOKEN_PUNCTUATION
    jne .body

    call punctuation_value
    cmp eax, P_COLON
    jne .body

    call advance

    call expect_identifier
    test rax, rax
    jz .fail

    mov [r9 + 32], rax

.body:

    call parse_block
    test rax, rax
    jz .fail

    mov [r9 + 40], rax

    mov rax, r9
    ret

.fail:
    xor eax, eax
    ret


parse_block:

    call expect_punctuation
    cmp eax, P_LBRACE
    jne .fail

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_BLOCK
    mov r8, rax

.loop:

    call token_type

    cmp eax, TOKEN_EOF
    je .fail

    cmp eax, TOKEN_PUNCTUATION
    jne .statement

    call punctuation_value
    cmp eax, P_RBRACE
    je .close

.statement:

    call parse_statement
    test rax, rax
    jz .fail

    mov r9, rax

    mov rdx, [r8 + 16]

    test rdx, rdx
    jz .first

    mov rcx, rdx

.find:

    mov r10, [rcx + 24]

    test r10, r10
    jz .append

    mov rcx, r10
    jmp .find

.append:

    mov [rcx + 24], r9
    jmp .loop

.first:

    mov [r8 + 16], r9
    jmp .loop

.close:

    call advance

    mov rax, r8
    ret

.fail:
    xor eax, eax
    ret


parse_return:

    call advance

    call token_type

    cmp eax, TOKEN_PUNCTUATION
    jne .value

    call punctuation_value

    cmp eax, P_SEMICOLON
    je .empty

    cmp eax, P_RBRACE
    je .empty

.value:

    call parse_expression
    test rax, rax
    jz .fail

    mov r8, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_RETURN
    mov [rax + 8], r8

    call consume_semicolon
    ret

.empty:

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_RETURN

    call consume_semicolon
    ret

.fail:
    xor eax, eax
    ret


parse_if:

    call advance

    call parse_expression
    test rax, rax
    jz .fail

    mov r8, rax

    call parse_block
    test rax, rax
    jz .fail

    mov r9, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_IF
    mov [rax + 8], r8
    mov [rax + 16], r9

    mov r10, rax

    call token_type
    cmp eax, TOKEN_KEYWORD
    jne .done

    call token_value
    cmp eax, KW_ELSE
    jne .done

    call advance

    call parse_block
    test rax, rax
    jz .fail

    mov [r10 + 24], rax

.done:
    mov rax, r10
    ret

.fail:
    xor eax, eax
    ret


parse_while:

    call advance

    call parse_expression
    test rax, rax
    jz .fail

    mov r8, rax

    call parse_block
    test rax, rax
    jz .fail

    mov r9, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_WHILE
    mov [rax + 8], r8
    mov [rax + 16], r9

    ret

.fail:
    xor eax, eax
    ret


parse_break:

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_BREAK

    call consume_semicolon
    ret

.fail:
    xor eax, eax
    ret


parse_continue:

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_CONTINUE

    call consume_semicolon
    ret

.fail:
    xor eax, eax
    ret


parse_expression:

    mov edi, 0
    call parse_binary
    ret


parse_binary:

    push rbp
    mov rbp, rsp

    push rbx
    push r12

    mov r12d, edi

    call parse_primary
    test rax, rax
    jz .fail

    mov rbx, rax

.loop:

    call token_type
    cmp eax, TOKEN_OPERATOR
    jne .done

    call token_value
    mov r8d, eax

    call precedence
    mov r9d, eax

    cmp r9d, r12d
    jle .done

    inc r9d

    mov edi, r9d
    push r8

    call advance
    call parse_binary

    pop r8

    test rax, rax
    jz .fail

    mov r10, rax

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_BINARY
    mov dword [rax + 4], r8d
    mov [rax + 8], rbx
    mov [rax + 16], r10

    mov rbx, rax
    jmp .loop

.done:

    mov rax, rbx

    pop r12
    pop rbx
    pop rbp
    ret

.fail:

    xor eax, eax

    pop r12
    pop rbx
    pop rbp
    ret


parse_primary:

    call token_type

    cmp eax, TOKEN_IDENTIFIER
    je .identifier

    cmp eax, TOKEN_INTEGER
    je .integer

    cmp eax, TOKEN_STRING
    je .string

    cmp eax, TOKEN_CHARACTER
    je .character

    cmp eax, TOKEN_KEYWORD
    je .keyword

    cmp eax, TOKEN_PUNCTUATION
    je .punctuation

    xor eax, eax
    ret

.identifier:

    call current_token
    mov r8, rax

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_IDENTIFIER
    mov [rax + 8], r8

    ret

.integer:

    call current_token
    mov r8, rax

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_INTEGER
    mov [rax + 8], r8

    ret

.string:

    call current_token
    mov r8, rax

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_STRING
    mov [rax + 8], r8

    ret

.character:

    call current_token
    mov r8, rax

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_CHARACTER
    mov [rax + 8], r8

    ret

.keyword:

    call token_value

    cmp eax, KW_TRUE
    je .boolean

    cmp eax, KW_FALSE
    je .boolean

    cmp eax, KW_NIL
    je .nil

    cmp eax, KW_SELF
    je .special

    cmp eax, KW_SUPER
    je .special

    xor eax, eax
    ret

.boolean:

    mov r8d, eax

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_BOOLEAN
    mov dword [rax + 4], r8d

    ret

.nil:

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_NIL

    ret

.special:

    mov r8d, eax

    call advance

    call new_node
    test rax, rax
    jz .fail

    mov dword [rax], NODE_IDENTIFIER
    mov dword [rax + 4], r8d

    ret

.punctuation:

    call punctuation_value

    cmp eax, P_OPEN
    je .parentheses

    xor eax, eax
    ret

.parentheses:

    call advance

    call parse_expression
    test rax, rax
    jz .fail

    mov r8, rax

    call expect_punctuation
    cmp eax, P_CLOSE
    jne .fail

    call advance

    mov rax, r8
    ret

.fail:
    xor eax, eax
    ret


precedence:

    cmp eax, OP_ASSIGN
    je .p1

    cmp eax, OP_OR
    je .p2

    cmp eax, OP_AND
    je .p3

    cmp eax, OP_EQ
    je .p4

    cmp eax, OP_NE
    je .p4

    cmp eax, OP_LT
    je .p5

    cmp eax, OP_GT
    je .p5

    cmp eax, OP_LE
    je .p5

    cmp eax, OP_GE
    je .p5

    cmp eax, OP_BITOR
    je .p6

    cmp eax, OP_XOR
    je .p7

    cmp eax, OP_BITAND
    je .p8

    cmp eax, OP_SHL
    je .p9

    cmp eax, OP_SHR
    je .p9

    cmp eax, OP_PLUS
    je .p10

    cmp eax, OP_MINUS
    je .p10

    cmp eax, OP_MUL
    je .p11

    cmp eax, OP_DIV
    je .p11

    cmp eax, OP_MOD
    je .p11

    xor eax, eax
    ret

.p1:
    mov eax, 1
    ret
.p2:
    mov eax, 2
    ret
.p3:
    mov eax, 3
    ret
.p4:
    mov eax, 4
    ret
.p5:
    mov eax, 5
    ret
.p6:
    mov eax, 6
    ret
.p7:
    mov eax, 7
    ret
.p8:
    mov eax, 8
    ret
.p9:
    mov eax, 9
    ret
.p10:
    mov eax, 10
    ret
.p11:
    mov eax, 11
    ret


expect_identifier:

    call token_type
    cmp eax, TOKEN_IDENTIFIER
    jne .fail

    call current_token
    mov r8, rax

    call advance

    mov rax, r8
    ret

.fail:
    xor eax, eax
    ret


expect_punctuation:

    call punctuation_value
    ret


consume_semicolon:

    call token_type
    cmp eax, TOKEN_PUNCTUATION
    jne .done

    call punctuation_value
    cmp eax, P_SEMICOLON
    jne .done

    call advance

.done:
    ret


current_token:

    mov rax, r14
    imul rax, TOKEN_SIZE
    add rax, r12
    ret


token_type:

    mov rax, r14
    imul rax, TOKEN_SIZE
    add rax, r12
    mov eax, [rax]
    ret


token_value:

    mov rax, r14
    imul rax, TOKEN_SIZE
    add rax, r12
    mov eax, [rax + 4]
    ret


punctuation_value:

    mov rax, r14
    imul rax, TOKEN_SIZE
    add rax, r12
    mov eax, [rax + 4]
    ret


advance:

    inc r14
    ret


new_node:

    mov edi, NODE_SIZE
    call malloc

    test rax, rax
    jz .fail

    xor rcx, rcx

.zero:

    cmp rcx, NODE_SIZE
    jae .done

    mov byte [rax + rcx], 0
    inc rcx
    jmp .zero

.done:
    ret

.fail:
    xor eax, eax
    ret