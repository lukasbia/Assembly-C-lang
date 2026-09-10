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
%define TOKEN_ERROR        8

%define KW_VAR             100
%define KW_LET             101
%define KW_IF              104
%define KW_ELSE            105
%define KW_WHILE           106
%define KW_DO              107
%define KW_FOR              108
%define KW_IN              109
%define KW_BREAK            110
%define KW_CONTINUE         111
%define KW_RETURN           112
%define KW_FUNCTION         113
%define KW_STRUCT           114
%define KW_CLASS            115
%define KW_ENUM             116
%define KW_PROTOCOL         117
%define KW_EXTENSION        118
%define KW_IMPORT           119
%define KW_PUBLIC           120
%define KW_PRIVATE          121
%define KW_INTERNAL         122
%define KW_FILEPRIVATE      123
%define KW_STATIC           124
%define KW_FINAL            125
%define KW_OPEN             126
%define KW_OVERRIDE         127
%define KW_INIT             128
%define KW_DEINIT           129
%define KW_SELF             130
%define KW_SUPER            131
%define KW_TRUE             132
%define KW_FALSE            133
%define KW_NIL              134
%define KW_AS               135
%define KW_IS               136
%define KW_TYPE             137
%define KW_PROTOCOLS        138
%define KW_GENERIC          139
%define KW_WHERE            140
%define KW_ASSOCIATED       141
%define KW_REQUIRES         142
%define KW_THROWS           143
%define KW_RETHROWS         144
%define KW_TRY              145
%define KW_CATCH            146
%define KW_THROW            147
%define KW_DEFER            148
%define KW_GUARD            149
%define KW_SWITCH            150
%define KW_CASE              151
%define KW_DEFAULT           152
%define KW_FALLTHROUGH       153
%define KW_REPEAT            154
%define KW_MATCH             155
%define KW_ASYNC             156
%define KW_AWAIT             157
%define KW_ACTOR             158
%define KW_TASK              159
%define KW_SEND              160
%define KW_RECEIVE           161
%define KW_MOVE              162
%define KW_COPY              163
%define KW_REFERENCE         164
%define KW_POINTER           165
%define KW_ADDRESS           166
%define KW_DEREFERENCE       167
%define KW_OPERATOR          168
%define KW_PRECEDENCE        169
%define KW_ASSOCIATIVITY     170
%define KW_INOUT             171
%define KW_VARIADIC          172
%define KW_EXTERN            173
%define KW_INLINE            174
%define KW_VOLATILE          175
%define KW_UNSAFE            176
%define KW_ASM               177
%define KW_SIZEOF            178
%define KW_ALIGNOF           179
%define KW_TYPEOF            180
%define KW_BITCAST           181
%define KW_UNREACHABLE       182
%define KW_EXTERN_C          183
%define KW_NAMESPACE         184
%define KW_USING             185
%define KW_ALIAS             186
%define KW_RESTRICT          187
%define KW_CONSTEXPR         188
%define KW_PACKED             189
%define KW_ALIGN              190
%define KW_SECTION            191
%define KW_EXPORT             192
%define KW_IMPORT_ASM         193
%define KW_LINK               194
%define KW_TARGET             195
%define KW_FUNC               196
%define KW_GET                197
%define KW_SET                198
%define KW_WILLSET            199
%define KW_DIDSET             200
%define KW_LAZY               201
%define KW_WEAK               202
%define KW_UNOWNED            203
%define KW_REQUIRED           204
%define KW_CONVENIENCE        205
%define KW_INDIRECT           206
%define KW_INFIX              207
%define KW_PREFIX             208
%define KW_POSTFIX            209
%define KW_PRECEDENCEGROUP    210
%define KW_TEMPLATE           211
%define KW_TYPENAME           212
%define KW_CONCEPT            213
%define KW_FRIEND             214
%define KW_VIRTUAL            215
%define KW_PROTECTED          216
%define KW_DELETE             217
%define KW_NEW                218
%define KW_THIS               219
%define KW_NULLPTR            220
%define KW_STATIC_ASSERT      221
%define KW_NOEXCEPT           222
%define KW_THREADLOCAL        223
%define KW_SYNCHRONIZED       224
%define KW_YIELD              225
%define KW_TYPEALIAS          226

%define OP_PLUS               1
%define OP_MINUS              2
%define OP_MULTIPLY           3
%define OP_DIVIDE             4
%define OP_MODULO             5
%define OP_ASSIGN             6
%define OP_EQUAL              7
%define OP_NOT_EQUAL          8
%define OP_LESS               9
%define OP_GREATER            10
%define OP_LESS_EQUAL         11
%define OP_GREATER_EQUAL      12
%define OP_AND                13
%define OP_OR                 14
%define OP_NOT                15
%define OP_BIT_AND            16
%define OP_BIT_OR             17
%define OP_BIT_XOR            18
%define OP_SHIFT_LEFT         19
%define OP_SHIFT_RIGHT        20
%define OP_INCREMENT          21
%define OP_DECREMENT          22
%define OP_ARROW              23
%define OP_RANGE              24
%define OP_OPTIONAL           25
%define OP_NULL_COALESCE      26
%define OP_PLUS_ASSIGN        27
%define OP_MINUS_ASSIGN       28
%define OP_MULT_ASSIGN        29
%define OP_DIV_ASSIGN         30

%define PAREN_OPEN            1
%define PAREN_CLOSE           2
%define BRACKET_OPEN         3
%define BRACKET_CLOSE        4
%define BRACE_OPEN            5
%define BRACE_CLOSE           6
%define COMMA                 7
%define COLON                 8
%define SEMICOLON             9
%define DOT                   10
%define QUESTION              11
%define AT                    12

%define NODE_PROGRAM          1
%define NODE_BLOCK            2
%define NODE_VAR_DECL         3
%define NODE_FUNCTION         4
%define NODE_PARAMETER        5
%define NODE_RETURN            6
%define NODE_IF               7
%define NODE_WHILE            8
%define NODE_BINARY           9
%define NODE_UNARY            10
%define NODE_ASSIGN            11
%define NODE_CALL              12
%define NODE_IDENTIFIER       13
%define NODE_INTEGER          14
%define NODE_STRING           15
%define NODE_CHARACTER        16
%define NODE_BOOLEAN          17
%define NODE_NIL              18
%define NODE_MEMBER           19
%define NODE_ARRAY            20

%define NODE_SIZE             128

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
    xor r15d, r15d

    call parser_program

    mov rbx, rax

    mov rax, rbx

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    pop rbp
    ret


parser_program:

    call ast_alloc

    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_PROGRAM
    mov dword [rax + 4], 0
    mov qword [rax + 8], 0
    mov qword [rax + 16], 0
    mov qword [rax + 24], 0
    mov qword [rax + 32], 0
    mov qword [rax + 40], 0
    mov qword [rax + 48], 0
    mov qword [rax + 56], 0

    mov r14, rax

.program_loop:

    call current_type

    cmp eax, TOKEN_EOF
    je .done

    call parse_statement

    test rax, rax
    jz parser_fail

    mov r15, rax

    mov rax, r14
    mov rdx, [rax + 16]

    test rdx, rdx
    jz .first

    mov rcx, rdx

.find_end:

    mov r8, [rcx + 24]

    test r8, r8
    jz .append

    mov rcx, r8
    jmp .find_end

.append:

    mov [rcx + 24], r15
    jmp .program_loop

.first:

    mov [rax + 16], r15
    jmp .program_loop

.done:

    mov rax, r14
    ret


parse_statement:

    call current_type

    cmp eax, TOKEN_KEYWORD
    jne .not_keyword

    call current_keyword

    cmp eax, KW_VAR
    je parse_variable

    cmp eax, KW_LET
    je parse_variable

    cmp eax, KW_FUNCTION
    je parse_function

    cmp eax, KW_FUNC
    je parse_function

    cmp eax, KW_RETURN
    je parse_return

    cmp eax, KW_IF
    je parse_if

    cmp eax, KW_WHILE
    je parse_while

    cmp eax, KW_BREAK
    je parse_break

    cmp eax, KW_CONTINUE
    je parse_continue

.not_keyword:

    cmp eax, TOKEN_PUNCTUATION
    jne .expression

    call current_punctuation

    cmp eax, BRACE_OPEN
    je parse_block

.expression:

    call parse_expression
    ret


parse_variable:

    call current_keyword
    mov r8d, eax

    call advance

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov r9, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_VAR_DECL
    mov dword [rax + 4], r8d
    mov [rax + 8], r9

    mov r10, rax

    call current_type
    cmp eax, TOKEN_PUNCTUATION
    jne .no_type

    call current_punctuation
    cmp eax, COLON
    jne .no_type

    call advance

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov [r10 + 16], rax

.no_type:

    call current_type

    cmp eax, TOKEN_OPERATOR
    jne .no_initializer

    call current_operator
    cmp eax, OP_ASSIGN
    jne .no_initializer

    call advance

    call parse_expression
    test rax, rax
    jz parser_fail

    mov [r10 + 24], rax

.no_initializer:

    call consume_semicolon

    mov rax, r10
    ret


parse_function:

    call advance

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov r8, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_FUNCTION
    mov [rax + 8], r8

    mov r9, rax

    call expect_punctuation
    cmp eax, PAREN_OPEN
    jne parser_fail

    call advance

.parameter_loop:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .parameter

    call current_punctuation
    cmp eax, PAREN_CLOSE
    je .parameters_done

.parameter:

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov r10, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_PARAMETER
    mov [rax + 8], r10

    mov r11, rax

    call current_type
    cmp eax, TOKEN_PUNCTUATION
    jne .parameter_append

    call current_punctuation
    cmp eax, COLON
    jne .parameter_append

    call advance

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov [r11 + 16], rax

.parameter_append:

    mov rdx, [r9 + 16]

    test rdx, rdx
    jz .first_parameter

    mov rcx, rdx

.find_parameter_end:

    mov r8, [rcx + 24]

    test r8, r8
    jz .append_parameter

    mov rcx, r8
    jmp .find_parameter_end

.append_parameter:

    mov [rcx + 24], r11
    jmp .after_parameter

.first_parameter:

    mov [r9 + 16], r11

.after_parameter:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .parameter_loop

    call current_punctuation
    cmp eax, COMMA
    jne .parameter_loop

    call advance
    jmp .parameter_loop

.parameters_done:

    call advance

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .body

    call current_punctuation
    cmp eax, COLON
    jne .body

    call advance

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov [r9 + 32], rax

.body:

    call parse_block
    test rax, rax
    jz parser_fail

    mov [r9 + 40], rax

    mov rax, r9
    ret


parse_return:

    call advance

    call current_type
    cmp eax, TOKEN_PUNCTUATION
    jne .value

    call current_punctuation
    cmp eax, SEMICOLON
    je .empty

    cmp eax, BRACE_CLOSE
    je .empty

.value:

    call parse_expression
    test rax, rax
    jz parser_fail

    mov r8, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_RETURN
    mov [rax + 8], r8

    call consume_semicolon
    ret

.empty:

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_RETURN

    call consume_semicolon
    ret


parse_if:

    call advance

    call parse_expression
    test rax, rax
    jz parser_fail

    mov r8, rax

    call parse_block
    test rax, rax
    jz parser_fail

    mov r9, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_IF
    mov [rax + 8], r8
    mov [rax + 16], r9

    mov r10, rax

    call current_type
    cmp eax, TOKEN_KEYWORD
    jne .done

    call current_keyword
    cmp eax, KW_ELSE
    jne .done

    call advance

    call parse_block
    test rax, rax
    jz parser_fail

    mov [r10 + 24], rax

.done:

    mov rax, r10
    ret


parse_while:

    call advance

    call parse_expression
    test rax, rax
    jz parser_fail

    mov r8, rax

    call parse_block
    test rax, rax
    jz parser_fail

    mov r9, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_WHILE
    mov [rax + 8], r8
    mov [rax + 16], r9

    ret


parse_break:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_BREAK

    call consume_semicolon

    ret


parse_continue:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_CONTINUE

    call consume_semicolon

    ret


parse_block:

    call expect_punctuation
    cmp eax, BRACE_OPEN
    jne parser_fail

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_BLOCK

    mov r8, rax

.block_loop:

    call current_type

    cmp eax, TOKEN_EOF
    je parser_fail

    cmp eax, TOKEN_PUNCTUATION
    jne .statement

    call current_punctuation
    cmp eax, BRACE_CLOSE
    je .close

.statement:

    call parse_statement
    test rax, rax
    jz parser_fail

    mov r9, rax

    mov rdx, [r8 + 16]

    test rdx, rdx
    jz .first

    mov rcx, rdx

.find_end:

    mov r10, [rcx + 24]

    test r10, r10
    jz .append

    mov rcx, r10
    jmp .find_end

.append:

    mov [rcx + 24], r9
    jmp .block_loop

.first:

    mov [r8 + 16], r9
    jmp .block_loop

.close:

    call advance

    mov rax, r8
    ret


parse_expression:

    mov edi, 0
    call parse_precedence
    ret


parse_precedence:

    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13

    mov r12d, edi

    cmp r12d, 12
    jg .primary

    call parse_unary
    test rax, rax
    jz .fail

    mov rbx, rax

.operator_loop:

    call current_type
    cmp eax, TOKEN_OPERATOR
    jne .done

    call current_operator
    mov r13d, eax

    call operator_precedence
    cmp eax, r12d
    jle .done

    mov edi, eax
    inc edi

    push r13
    push rbx

    call parse_precedence

    pop rbx
    pop r13

    test rax, rax
    jz .fail

    mov rdx, rax

    call ast_alloc
    test rax, rax
    jz .fail

    mov dword [rax], NODE_BINARY
    mov dword [rax + 4], r13d
    mov [rax + 8], rbx
    mov [rax + 16], rdx

    mov rbx, rax
    jmp .operator_loop

.primary:

    call parse_unary
    test rax, rax
    jz .fail

.done:

    mov rax, rbx

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


parse_unary:

    call current_type

    cmp eax, TOKEN_OPERATOR
    jne parse_primary

    call current_operator

    cmp eax, OP_MINUS
    je unary_operator

    cmp eax, OP_PLUS
    je unary_operator

    cmp eax, OP_NOT
    je unary_operator

    cmp eax, OP_BIT_AND
    je unary_operator

    cmp eax, OP_MULTIPLY
    je unary_operator

    jmp parse_primary

unary_operator:

    mov r8d, eax

    call advance

    call parse_unary
    test rax, rax
    jz parser_fail

    mov r9, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_UNARY
    mov dword [rax + 4], r8d
    mov [rax + 8], r9

    ret


parse_primary:

    call current_type

    cmp eax, TOKEN_IDENTIFIER
    je primary_identifier

    cmp eax, TOKEN_INTEGER
    je primary_integer

    cmp eax, TOKEN_STRING
    je primary_string

    cmp eax, TOKEN_CHARACTER
    je primary_character

    cmp eax, TOKEN_KEYWORD
    je primary_keyword

    cmp eax, TOKEN_PUNCTUATION
    je primary_punctuation

    xor eax, eax
    ret


primary_identifier:

    call current_token

    mov r8, rax

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_IDENTIFIER
    mov [rax + 8], r8

    mov r9, rax

    call parse_postfix

    ret


primary_integer:

    call current_token

    mov r8, rax

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_INTEGER
    mov [rax + 8], r8

    ret


primary_string:

    call current_token

    mov r8, rax

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_STRING
    mov [rax + 8], r8

    ret


primary_character:

    call current_token

    mov r8, rax

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_CHARACTER
    mov [rax + 8], r8

    ret


primary_keyword:

    call current_keyword

    cmp eax, KW_TRUE
    je primary_boolean

    cmp eax, KW_FALSE
    je primary_boolean

    cmp eax, KW_NIL
    je primary_nil

    cmp eax, KW_SELF
    je primary_self

    cmp eax, KW_SUPER
    je primary_super

    xor eax, eax
    ret


primary_boolean:

    mov r8d, eax

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_BOOLEAN
    mov dword [rax + 4], r8d

    ret


primary_nil:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_NIL

    ret


primary_self:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_IDENTIFIER
    mov dword [rax + 4], KW_SELF

    ret


primary_super:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_IDENTIFIER
    mov dword [rax + 4], KW_SUPER

    ret


primary_punctuation:

    call current_punctuation

    cmp eax, PAREN_OPEN
    je parse_parenthesized

    cmp eax, BRACKET_OPEN
    je parse_array

    ret


parse_parenthesized:

    call advance

    call parse_expression
    test rax, rax
    jz parser_fail

    mov r8, rax

    call expect_punctuation
    cmp eax, PAREN_CLOSE
    jne parser_fail

    call advance

    mov rax, r8

    call parse_postfix

    ret


parse_array:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_ARRAY

    mov r8, rax

.array_loop:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .element

    call current_punctuation

    cmp eax, BRACKET_CLOSE
    je .done

.element:

    call parse_expression
    test rax, rax
    jz parser_fail

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
    jmp .comma

.first:

    mov [r8 + 16], r9

.comma:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .array_loop

    call current_punctuation
    cmp eax, COMMA
    jne .done

    call advance
    jmp .array_loop

.done:

    call advance

    mov rax, r8

    call parse_postfix

    ret


parse_postfix:

    mov r10, rax

.loop:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    je .punctuation

    cmp eax, TOKEN_OPERATOR
    je .operator

    jmp .done

.punctuation:

    call current_punctuation

    cmp eax, PAREN_OPEN
    je .call

    cmp eax, DOT
    je .member

    jmp .done

.call:

    call advance

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_CALL
    mov [rax + 8], r10

    mov r11, rax

.call_args:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .argument

    call current_punctuation
    cmp eax, PAREN_CLOSE
    je .call_done

.argument:

    call parse_expression
    test rax, rax
    jz parser_fail

    mov r8, rax

    mov rdx, [r11 + 16]

    test rdx, rdx
    jz .first_arg

    mov rcx, rdx

.find_arg:

    mov r9, [rcx + 24]

    test r9, r9
    jz .append_arg

    mov rcx, r9
    jmp .find_arg

.append_arg:

    mov [rcx + 24], r8
    jmp .next_arg

.first_arg:

    mov [r11 + 16], r8

.next_arg:

    call current_type
    cmp eax, TOKEN_PUNCTUATION
    jne .call_args

    call current_punctuation
    cmp eax, COMMA
    jne .call_done

    call advance
    jmp .call_args

.call_done:

    call advance

    mov r10, r11
    jmp .loop

.member:

    call advance

    call expect_identifier
    test rax, rax
    jz parser_fail

    mov r8, rax

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_MEMBER
    mov [rax + 8], r10
    mov [rax + 16], r8

    mov r10, rax
    jmp .loop

.operator:

    call current_operator

    cmp eax, OP_INCREMENT
    je .postfix_inc

    cmp eax, OP_DECREMENT
    je .postfix_dec

    jmp .done

.postfix_inc:

    mov r8d, eax
    call advance
    jmp .make_postfix

.postfix_dec:

    mov r8d, eax
    call advance

.make_postfix:

    call ast_alloc
    test rax, rax
    jz parser_fail

    mov dword [rax], NODE_UNARY
    mov dword [rax + 4], r8d
    mov [rax + 8], r10

    mov r10, rax
    jmp .loop

.done:

    mov rax, r10
    ret


operator_precedence:

    cmp eax, OP_ASSIGN
    je .assignment

    cmp eax, OP_PLUS_ASSIGN
    je .assignment

    cmp eax, OP_MINUS_ASSIGN
    je .assignment

    cmp eax, OP_MULT_ASSIGN
    je .assignment

    cmp eax, OP_DIV_ASSIGN
    je .assignment

    cmp eax, OP_OR
    je .logical_or

    cmp eax, OP_AND
    je .logical_and

    cmp eax, OP_EQUAL
    je .equality

    cmp eax, OP_NOT_EQUAL
    je .equality

    cmp eax, OP_LESS
    je .comparison

    cmp eax, OP_GREATER
    je .comparison

    cmp eax, OP_LESS_EQUAL
    je .comparison

    cmp eax, OP_GREATER_EQUAL
    je .comparison

    cmp eax, OP_BIT_OR
    je .bit_or

    cmp eax, OP_BIT_XOR
    je .bit_xor

    cmp eax, OP_BIT_AND
    je .bit_and

    cmp eax, OP_SHIFT_LEFT
    je .shift

    cmp eax, OP_SHIFT_RIGHT
    je .shift

    cmp eax, OP_PLUS
    je .addition

    cmp eax, OP_MINUS
    je .addition

    cmp eax, OP_MULTIPLY
    je .multiplication

    cmp eax, OP_DIVIDE
    je .multiplication

    cmp eax, OP_MODULO
    je .multiplication

    xor eax, eax
    ret

.assignment:
    mov eax, 1
    ret

.logical_or:
    mov eax, 2
    ret

.logical_and:
    mov eax, 3
    ret

.equality:
    mov eax, 4
    ret

.comparison:
    mov eax, 5
    ret

.bit_or:
    mov eax, 6
    ret

.bit_xor:
    mov eax, 7
    ret

.bit_and:
    mov eax, 8
    ret

.shift:
    mov eax, 9
    ret

.addition:
    mov eax, 10
    ret

.multiplication:
    mov eax, 11
    ret


expect_identifier:

    call current_type
    cmp eax, TOKEN_IDENTIFIER
    jne parser_fail

    call current_token
    mov r8, rax

    call advance

    mov rax, r8
    ret


expect_punctuation:

    call current_punctuation
    ret


consume_semicolon:

    call current_type

    cmp eax, TOKEN_PUNCTUATION
    jne .done

    call current_punctuation
    cmp eax, SEMICOLON
    jne .done

    call advance

.done:
    ret


current_token:

    mov rax, r14
    imul rax, 32
    add rax, r12
    ret


current_type:

    cmp r14, r13
    jae .eof

    mov rax, r14
    imul rax, 32
    add rax, r12

    mov eax, [rax]
    ret

.eof:

    mov eax, TOKEN_EOF
    ret


current_keyword:

    mov rax, r14
    imul rax, 32
    add rax, r12

    mov eax, [rax + 4]
    ret


current_operator:

    mov rax, r14
    imul rax, 32
    add rax, r12

    mov eax, [rax + 4]
    ret


current_punctuation:

    mov rax, r14
    imul rax, 32
    add rax, r12

    mov eax, [rax + 4]
    ret


advance:

    inc r14
    ret


ast_alloc:

    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9

    mov edi, NODE_SIZE
    call malloc

    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi

    test rax, rax
    jz .failed

    xor rcx, rcx

.zero:

    cmp rcx, NODE_SIZE
    jae .done

    mov byte [rax + rcx], 0
    inc rcx
    jmp .zero

.done:

    ret

.failed:

    xor eax, eax
    ret


parser_fail:

    xor eax, eax
    ret


section .bss

ast_error:
    resq 1