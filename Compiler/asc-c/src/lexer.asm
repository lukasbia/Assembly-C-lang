bits 64

global asc_lexer

%define TOKEN_EOF          0
%define TOKEN_IDENTIFIER   1
%define TOKEN_INTEGER      2
%define TOKEN_STRING       3
%define TOKEN_CHARACTER    4
%define TOKEN_KEYWORD      5
%define TOKEN_OPERATOR     6
%define TOKEN_PUNCTUATION  7
%define TOKEN_ERROR        8

%define OP_PLUS            1
%define OP_MINUS           2
%define OP_MULTIPLY        3
%define OP_DIVIDE          4
%define OP_MODULO          5
%define OP_ASSIGN          6
%define OP_EQUAL           7
%define OP_NOT_EQUAL       8
%define OP_LESS            9
%define OP_GREATER         10
%define OP_LESS_EQUAL      11
%define OP_GREATER_EQUAL   12
%define OP_AND             13
%define OP_OR              14
%define OP_NOT             15
%define OP_BIT_AND         16
%define OP_BIT_OR          17
%define OP_BIT_XOR         18
%define OP_SHIFT_LEFT      19
%define OP_SHIFT_RIGHT     20
%define OP_INCREMENT       21
%define OP_DECREMENT       22
%define OP_ARROW           23
%define OP_RANGE           24
%define OP_OPTIONAL        25
%define OP_NULL_COALESCE   26
%define OP_PLUS_ASSIGN     27
%define OP_MINUS_ASSIGN    28
%define OP_MULT_ASSIGN     29
%define OP_DIV_ASSIGN      30

%define PAREN_OPEN         1
%define PAREN_CLOSE        2
%define BRACKET_OPEN       3
%define BRACKET_CLOSE      4
%define BRACE_OPEN         5
%define BRACE_CLOSE        6
%define COMMA              7
%define COLON              8
%define SEMICOLON          9
%define DOT                10
%define QUESTION           11
%define AT                 12

%define KW_VAR             100
%define KW_LET             101
%define KW_MUTABLE         102
%define KW_IMMUTABLE       103
%define KW_IF              104
%define KW_ELSE            105
%define KW_WHILE           106
%define KW_DO              107
%define KW_FOR             108
%define KW_IN              109
%define KW_BREAK           110
%define KW_CONTINUE        111
%define KW_RETURN          112
%define KW_FUNCTION        113
%define KW_STRUCT          114
%define KW_CLASS           115
%define KW_ENUM            116
%define KW_PROTOCOL        117
%define KW_EXTENSION       118
%define KW_IMPORT          119
%define KW_PUBLIC          120
%define KW_PRIVATE         121
%define KW_INTERNAL        122
%define KW_FILEPRIVATE     123
%define KW_STATIC          124
%define KW_FINAL           125
%define KW_OPEN            126
%define KW_OVERRIDE        127
%define KW_INIT            128
%define KW_DEINIT          129
%define KW_SELF            130
%define KW_SUPER           131
%define KW_TRUE            132
%define KW_FALSE           133
%define KW_NIL             134
%define KW_AS              135
%define KW_IS              136
%define KW_TYPE            137
%define KW_PROTOCOLS       138
%define KW_GENERIC         139
%define KW_WHERE           140
%define KW_ASSOCIATED      141
%define KW_REQUIRES        142
%define KW_THROWS          143
%define KW_RETHROWS        144
%define KW_TRY             145
%define KW_CATCH           146
%define KW_THROW           147
%define KW_DEFER           148
%define KW_GUARD           149
%define KW_SWITCH           150
%define KW_CASE             151
%define KW_DEFAULT          152
%define KW_FALLTHROUGH      153
%define KW_REPEAT           154
%define KW_MATCH            155
%define KW_ASYNC            156
%define KW_AWAIT            157
%define KW_ACTOR            158
%define KW_TASK             159
%define KW_SEND             160
%define KW_RECEIVE          161
%define KW_MOVE             162
%define KW_COPY             163
%define KW_REFERENCE        164
%define KW_POINTER          165
%define KW_ADDRESS          166
%define KW_DEREFERENCE      167
%define KW_OPERATOR         168
%define KW_PRECEDENCE       169
%define KW_ASSOCIATIVITY    170
%define KW_INOUT            171
%define KW_VARIADIC         172
%define KW_EXTERN           173
%define KW_INLINE           174
%define KW_VOLATILE         175
%define KW_UNSAFE           176
%define KW_ASM              177
%define KW_SIZEOF           178
%define KW_ALIGNOF          179
%define KW_TYPEOF           180
%define KW_BITCAST          181
%define KW_UNREACHABLE      182
%define KW_EXTERN_C         183
%define KW_NAMESPACE        184
%define KW_USING             185
%define KW_ALIAS             186
%define KW_RESTRICT          187
%define KW_CONSTEXPR         188
%define KW_PACKED            189
%define KW_ALIGN             190
%define KW_SECTION           191
%define KW_EXPORT            192
%define KW_IMPORT_ASM        193
%define KW_LINK              194
%define KW_TARGET            195
%define KW_FUNC              196
%define KW_GET               197
%define KW_SET               198
%define KW_WILLSET           199
%define KW_DIDSET            200
%define KW_LAZY              201
%define KW_WEAK              202
%define KW_UNOWNED           203
%define KW_REQUIRED          204
%define KW_CONVENIENCE       205
%define KW_INDIRECT          206
%define KW_INFIX             207
%define KW_PREFIX            208
%define KW_POSTFIX           209
%define KW_PRECEDENCEGROUP   210
%define KW_TEMPLATE          211
%define KW_TYPENAME          212
%define KW_CONCEPT           213
%define KW_FRIEND            214
%define KW_VIRTUAL           215
%define KW_PROTECTED         216
%define KW_DELETE            217
%define KW_NEW               218
%define KW_THIS              219
%define KW_NULLPTR           220
%define KW_STATIC_ASSERT     221
%define KW_NOEXCEPT          222
%define KW_THREADLOCAL       223
%define KW_SYNCHRONIZED      224
%define KW_YIELD             225
%define KW_TYPEALIAS         226

section .text

asc_lexer:

    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi
    mov r13, rsi

    xor r14, r14
    xor r15, r15

    lea rbx, [token_buffer]

lexer_loop:

    cmp r14, r13
    jae lexer_finish

    mov al, [r12 + r14]

    cmp al, ' '
    je skip_character

    cmp al, 9
    je skip_character

    cmp al, 10
    je skip_character

    cmp al, 13
    je skip_character

    cmp al, '/'
    jne check_identifier

    mov rax, r14
    inc rax

    cmp rax, r13
    jae check_operator

    mov dl, [r12 + rax]

    cmp dl, '/'
    je line_comment

    cmp dl, '*'
    je block_comment

    jmp check_operator

line_comment:

    add r14, 2

line_comment_loop:

    cmp r14, r13
    jae lexer_loop

    mov al, [r12 + r14]

    inc r14

    cmp al, 10
    jne line_comment_loop

    jmp lexer_loop

block_comment:

    add r14, 2

block_comment_loop:

    cmp r14, r13
    jae unterminated_comment

    mov al, [r12 + r14]

    cmp al, '*'
    jne block_comment_next

    mov rax, r14
    inc rax

    cmp rax, r13
    jae block_comment_next

    mov dl, [r12 + rax]

    cmp dl, '/'
    je block_comment_end

block_comment_next:

    inc r14
    jmp block_comment_loop

block_comment_end:

    add r14, 2
    jmp lexer_loop

check_identifier:

    mov al, [r12 + r14]

    call is_identifier_start

    test eax, eax
    jz check_number

    mov r8, r14

identifier_loop:

    cmp r14, r13
    jae identifier_finished

    mov al, [r12 + r14]

    call is_identifier_character

    test eax, eax
    jz identifier_finished

    inc r14
    jmp identifier_loop

identifier_finished:

    mov r9, r14
    sub r9, r8

    lea rsi, [r12 + r8]
    mov rdx, r9

    call lookup_keyword

    test eax, eax
    jz emit_identifier

    mov dword [rbx], TOKEN_KEYWORD
    mov dword [rbx + 4], eax
    mov qword [rbx + 8], rsi
    mov qword [rbx + 16], r9
    mov qword [rbx + 24], r8

    add rbx, 32
    inc r15

    jmp lexer_loop

emit_identifier:

    mov dword [rbx], TOKEN_IDENTIFIER
    mov dword [rbx + 4], 0
    mov qword [rbx + 8], rsi
    mov qword [rbx + 16], r9
    mov qword [rbx + 24], r8

    add rbx, 32
    inc r15

    jmp lexer_loop

check_number:

    mov al, [r12 + r14]

    cmp al, '0'
    jb check_string

    cmp al, '9'
    ja check_string

    mov r8, r14
    xor r9, r9

number_loop:

    cmp r14, r13
    jae number_finished

    mov al, [r12 + r14]

    cmp al, '0'
    jb number_finished

    cmp al, '9'
    ja number_finished

    sub al, '0'
    movzx rax, al

    imul r9, r9, 10
    add r9, rax

    inc r14

    jmp number_loop

number_finished:

    mov dword [rbx], TOKEN_INTEGER
    mov dword [rbx + 4], 0
    mov qword [rbx + 8], r8
    mov qword [rbx + 16], r14
    sub qword [rbx + 16], r8
    mov qword [rbx + 24], r9

    add rbx, 32
    inc r15

    jmp lexer_loop

check_string:

    cmp al, '"'
    je string_literal

    cmp al, "'"
    je character_literal

    jmp check_operator

string_literal:

    mov r8, r14
    inc r14

string_loop:

    cmp r14, r13
    jae unterminated_string

    mov al, [r12 + r14]

    cmp al, '\'
    jne string_normal

    mov rax, r14
    inc rax

    cmp rax, r13
    jae unterminated_string

    add r14, 2
    jmp string_loop

string_normal:

    cmp al, '"'
    je string_finished

    cmp al, 10
    je unterminated_string

    inc r14
    jmp string_loop

string_finished:

    inc r14

    mov dword [rbx], TOKEN_STRING
    mov dword [rbx + 4], 0
    mov qword [rbx + 8], r8
    mov qword [rbx + 16], r14
    sub qword [rbx + 16], r8
    mov qword [rbx + 24], r8

    add rbx, 32
    inc r15

    jmp lexer_loop

character_literal:

    mov r8, r14
    inc r14

character_loop:

    cmp r14, r13
    jae unterminated_character

    mov al, [r12 + r14]

    cmp al, '\'
    jne character_normal

    mov rax, r14
    inc rax

    cmp rax, r13
    jae unterminated_character

    add r14, 2
    jmp character_loop

character_normal:

    cmp al, "'"
    je character_finished

    cmp al, 10
    je unterminated_character

    inc r14
    jmp character_loop

character_finished:

    inc r14

    mov dword [rbx], TOKEN_CHARACTER
    mov dword [rbx + 4], 0
    mov qword [rbx + 8], r8
    mov qword [rbx + 16], r14
    sub qword [rbx + 16], r8
    mov qword [rbx + 24], r8

    add rbx, 32
    inc r15

    jmp lexer_loop

check_operator:

    mov al, [r12 + r14]

    cmp al, '+'
    je lex_plus

    cmp al, '-'
    je lex_minus

    cmp al, '*'
    je lex_star

    cmp al, '/'
    je lex_slash

    cmp al, '%'
    je lex_modulo

    cmp al, '='
    je lex_equal

    cmp al, '!'
    je lex_not

    cmp al, '<'
    je lex_less

    cmp al, '>'
    je lex_greater

    cmp al, '&'
    je lex_ampersand

    cmp al, '|'
    je lex_pipe

    cmp al, '^'
    je lex_xor

    cmp al, '?'
    je lex_question

    jmp check_punctuation

lex_plus:

    mov eax, OP_PLUS
    call check_plus_variants
    jmp emit_operator

check_plus_variants:

    mov r10, r14
    inc r10

    cmp r10, r13
    jae .done

    mov dl, [r12 + r10]

    cmp dl, '+'
    je .increment

    cmp dl, '='
    je .assign

.done:

    ret

.increment:

    mov eax, OP_INCREMENT
    add r14, 2
    jmp emit_operator_direct

.assign:

    mov eax, OP_PLUS_ASSIGN
    add r14, 2
    jmp emit_operator_direct

lex_minus:

    mov eax, OP_MINUS

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '-'
    je minus_increment

    cmp dl, '>'
    je minus_arrow

    cmp dl, '='
    je minus_assign

    jmp emit_operator

minus_increment:

    mov eax, OP_DECREMENT
    add r14, 2
    jmp emit_operator_direct

minus_arrow:

    mov eax, OP_ARROW
    add r14, 2
    jmp emit_operator_direct

minus_assign:

    mov eax, OP_MINUS_ASSIGN
    add r14, 2
    jmp emit_operator_direct

lex_star:

    mov eax, OP_MULTIPLY

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '='
    je multiply_assign

    jmp emit_operator

multiply_assign:

    mov eax, OP_MULT_ASSIGN
    add r14, 2
    jmp emit_operator_direct

lex_slash:

    mov eax, OP_DIVIDE
    jmp emit_operator

lex_modulo:

    mov eax, OP_MODULO
    jmp emit_operator

lex_equal:

    mov eax, OP_ASSIGN

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '='
    je equality

equality:

    mov eax, OP_EQUAL
    add r14, 2
    jmp emit_operator_direct

lex_not:

    mov eax, OP_NOT

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '='
    je not_equal

    jmp emit_operator

not_equal:

    mov eax, OP_NOT_EQUAL
    add r14, 2
    jmp emit_operator_direct

lex_less:

    mov eax, OP_LESS

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '='
    je less_equal

    cmp dl, '<'
    je shift_left

    jmp emit_operator

less_equal:

    mov eax, OP_LESS_EQUAL
    add r14, 2
    jmp emit_operator_direct

shift_left:

    mov eax, OP_SHIFT_LEFT
    add r14, 2
    jmp emit_operator_direct

lex_greater:

    mov eax, OP_GREATER

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '='
    je greater_equal

    cmp dl, '>'
    je shift_right

    jmp emit_operator

greater_equal:

    mov eax, OP_GREATER_EQUAL
    add r14, 2
    jmp emit_operator_direct

shift_right:

    mov eax, OP_SHIFT_RIGHT
    add r14, 2
    jmp emit_operator_direct

lex_ampersand:

    mov eax, OP_BIT_AND

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '&'
    jne emit_operator

    mov eax, OP_AND
    add r14, 2
    jmp emit_operator_direct

lex_pipe:

    mov eax, OP_BIT_OR

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '|'
    jne emit_operator

    mov eax, OP_OR
    add r14, 2
    jmp emit_operator_direct

lex_xor:

    mov eax, OP_BIT_XOR
    jmp emit_operator

lex_question:

    mov eax, OP_OPTIONAL

    mov r10, r14
    inc r10

    cmp r10, r13
    jae emit_operator

    mov dl, [r12 + r10]

    cmp dl, '?'
    jne emit_operator

    mov eax, OP_NULL_COALESCE
    add r14, 2

emit_operator_direct:

    mov dword [rbx], TOKEN_OPERATOR
    mov dword [rbx + 4], eax
    mov qword [rbx + 8], 0
    mov qword [rbx + 16], 0
    mov qword [rbx + 24], r14

    add rbx, 32
    inc r15

    jmp lexer_loop

emit_operator:

    inc r14
    jmp emit_operator_direct

check_punctuation:

    mov al, [r12 + r14]

    cmp al, '('
    je punctuation_paren_open

    cmp al, ')'
    je punctuation_paren_close

    cmp al, '['
    je punctuation_bracket_open

    cmp al, ']'
    je punctuation_bracket_close

    cmp al, '{'
    je punctuation_brace_open

    cmp al, '}'
    je punctuation_brace_close

    cmp al, ','
    je punctuation_comma

    cmp al, ':'
    je punctuation_colon

    cmp al, ';'
    je punctuation_semicolon

    cmp al, '.'
    je punctuation_dot

    cmp al, '@'
    je punctuation_at

    jmp unknown_character

punctuation_paren_open:

    mov eax, PAREN_OPEN
    jmp emit_punctuation

punctuation_paren_close:

    mov eax, PAREN_CLOSE
    jmp emit_punctuation

punctuation_bracket_open:

    mov eax, BRACKET_OPEN
    jmp emit_punctuation

punctuation_bracket_close:

    mov eax, BRACKET_CLOSE
    jmp emit_punctuation

punctuation_brace_open:

    mov eax, BRACE_OPEN
    jmp emit_punctuation

punctuation_brace_close:

    mov eax, BRACE_CLOSE
    jmp emit_punctuation

punctuation_comma:

    mov eax, COMMA
    jmp emit_punctuation

punctuation_colon:

    mov eax, COLON
    jmp emit_punctuation

punctuation_semicolon:

    mov eax, SEMICOLON
    jmp emit_punctuation

punctuation_dot:

    mov eax, DOT
    jmp emit_punctuation

punctuation_at:

    mov eax, AT

emit_punctuation:

    mov dword [rbx], TOKEN_PUNCTUATION
    mov dword [rbx + 4], eax
    mov qword [rbx + 8], r14
    mov qword [rbx + 16], 1
    mov qword [rbx + 24], r14

    add rbx, 32
    inc r15
    inc r14

    jmp lexer_loop

unknown_character:

    mov dword [rbx], TOKEN_ERROR
    mov dword [rbx + 4], 1
    mov qword [rbx + 8], r14
    mov qword [rbx + 16], 1
    mov qword [rbx + 24], r14

    add rbx, 32
    inc r15
    inc r14

    jmp lexer_loop

unterminated_string:

    mov dword [rbx], TOKEN_ERROR
    mov dword [rbx + 4], 2
    mov qword [rbx + 8], r8
    mov qword [rbx + 16], r14
    sub qword [rbx + 16], r8
    mov qword [rbx + 24], r8

    add rbx, 32
    inc r15
    jmp lexer_finish

unterminated_character:

    mov dword [rbx], TOKEN_ERROR
    mov dword [rbx + 4], 3
    mov qword [rbx + 8], r8
    mov qword [rbx + 16], r14
    sub qword [rbx + 16], r8
    mov qword [rbx + 24], r8

    add rbx, 32
    inc r15
    jmp lexer_finish

unterminated_comment:

    mov dword [rbx], TOKEN_ERROR
    mov dword [rbx + 4], 4
    mov qword [rbx + 8], r14
    mov qword [rbx + 16], 0
    mov qword [rbx + 24], r14

    add rbx, 32
    inc r15

lexer_finish:

    mov dword [rbx], TOKEN_EOF
    mov dword [rbx + 4], 0
    mov qword [rbx + 8], 0
    mov qword [rbx + 16], 0
    mov qword [rbx + 24], r14

    mov rax, r15
    lea rdx, [token_buffer]

    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp

    ret

is_identifier_start:

    cmp al, '_'
    je identifier_true

    cmp al, 'A'
    jb identifier_false

    cmp al, 'Z'
    jbe identifier_true

    cmp al, 'a'
    jb identifier_false

    cmp al, 'z'
    jbe identifier_true

identifier_false:

    xor eax, eax
    ret

identifier_true:

    mov eax, 1
    ret

is_identifier_character:

    call is_identifier_start

    test eax, eax
    jnz identifier_character_true

    cmp al, '0'
    jb identifier_character_false

    cmp al, '9'
    ja identifier_character_false

identifier_character_true:

    mov eax, 1
    ret

identifier_character_false:

    xor eax, eax
    ret

lookup_keyword:

    push rbx
    push rcx
    push r8
    push r9
    push r10
    push r11

    xor rcx, rcx

keyword_loop:

    cmp rcx, 127
    jae keyword_not_found

    mov r8, rcx
    imul r8, 24

    lea r9, [keyword_table + r8]

    mov r10, [r9]

    cmp r10, rdx
    jne keyword_next

    mov r11, [r9 + 8]

    xor r8, r8

keyword_compare:

    cmp r8, rdx
    jae keyword_found

    mov al, [rsi + r8]
    mov ah, [r11 + r8]

    cmp al, ah
    jne keyword_next

    inc r8
    jmp keyword_compare

keyword_found:

    mov eax, [r9 + 16]

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rbx

    ret

keyword_next:

    inc rcx
    jmp keyword_loop

keyword_not_found:

    xor eax, eax

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rbx

    ret

section .data

kw_var              db "var",0
kw_let              db "let",0
kw_mutable          db "mutable",0
kw_immutable        db "immutable",0
kw_if               db "if",0
kw_else             db "else",0
kw_while            db "while",0
kw_do                db "do",0
kw_for               db "for",0
kw_in                db "in",0
kw_break             db "break",0
kw_continue          db "continue",0
kw_return            db "return",0
kw_function          db "function",0
kw_struct            db "struct",0
kw_class             db "class",0
kw_enum              db "enum",0
kw_protocol          db "protocol",0
kw_extension         db "extension",0
kw_import            db "import",0
kw_public            db "public",0
kw_private           db "private",0
kw_internal          db "internal",0
kw_fileprivate       db "fileprivate",0
kw_static            db "static",0
kw_final             db "final",0
kw_open              db "open",0
kw_override           db "override",0
kw_init              db "init",0
kw_deinit            db "deinit",0
kw_self              db "self",0
kw_super             db "super",0
kw_true              db "true",0
kw_false             db "false",0
kw_nil               db "nil",0
kw_as                db "as",0
kw_is                db "is",0
kw_type              db "type",0
kw_protocols         db "protocols",0
kw_generic           db "generic",0
kw_where             db "where",0
kw_associated        db "associated",0
kw_requires          db "requires",0
kw_throws            db "throws",0
kw_rethrows          db "rethrows",0
kw_try               db "try",0
kw_catch             db "catch",0
kw_throw             db "throw",0
kw_defer             db "defer",0
kw_guard             db "guard",0
kw_switch            db "switch",0
kw_case              db "case",0
kw_default            db "default",0
kw_fallthrough       db "fallthrough",0
kw_repeat             db "repeat",0
kw_match              db "match",0
kw_async              db "async",0
kw_await              db "await",0
kw_actor              db "actor",0
kw_task               db "task",0
kw_send               db "send",0
kw_receive            db "receive",0
kw_move               db "move",0
kw_copy               db "copy",0
kw_reference          db "reference",0
kw_pointer            db "pointer",0
kw_address            db "address",0
kw_dereference        db "dereference",0
kw_operator           db "operator",0
kw_precedence         db "precedence",0
kw_associativity      db "associativity",0
kw_inout              db "inout",0
kw_variadic            db "variadic",0
kw_extern              db "extern",0
kw_inline              db "inline",0
kw_volatile            db "volatile",0
kw_unsafe              db "unsafe",0
kw_asm                 db "asm",0
kw_sizeof              db "sizeof",0
kw_alignof             db "alignof",0
kw_typeof              db "typeof",0
kw_bitcast             db "bitcast",0
kw_unreachable         db "unreachable",0
kw_extern_c            db "extern_c",0
kw_namespace           db "namespace",0
kw_using               db "using",0
kw_alias               db "alias",0
kw_restrict            db "restrict",0
kw_constexpr           db "constexpr",0
kw_packed              db "packed",0
kw_align               db "align",0
kw_section             db "section",0
kw_export              db "export",0
kw_import_asm          db "import_asm",0
kw_link                db "link",0
kw_target              db "target",0
kw_func                db "func",0
kw_get                 db "get",0
kw_set                 db "set",0
kw_willset             db "willSet",0
kw_didset              db "didSet",0
kw_lazy                db "lazy",0
kw_weak                db "weak",0
kw_unowned             db "unowned",0
kw_required            db "required",0
kw_convenience         db "convenience",0
kw_indirect            db "indirect",0
kw_infix               db "infix",0
kw_prefix              db "prefix",0
kw_postfix             db "postfix",0
kw_precedencegroup     db "precedencegroup",0
kw_template            db "template",0
kw_typename            db "typename",0
kw_concept             db "concept",0
kw_friend              db "friend",0
kw_virtual             db "virtual",0
kw_protected           db "protected",0
kw_delete              db "delete",0
kw_new                 db "new",0
kw_this                db "this",0
kw_nullptr              db "nullptr",0
kw_static_assert       db "static_assert",0
kw_noexcept            db "noexcept",0
kw_threadlocal         db "threadlocal",0
kw_synchronized        db "synchronized",0
kw_yield               db "yield",0
kw_typealias           db "typealias",0

keyword_table:

dq 3,  kw_var,             KW_VAR
dq 3,  kw_let,             KW_LET
dq 7,  kw_mutable,         KW_MUTABLE
dq 9,  kw_immutable,       KW_IMMUTABLE
dq 2,  kw_if,              KW_IF
dq 4,  kw_else,            KW_ELSE
dq 5,  kw_while,           KW_WHILE
dq 2,  kw_do,               KW_DO
dq 3,  kw_for,              KW_FOR
dq 2,  kw_in,               KW_IN
dq 5,  kw_break,            KW_BREAK
dq 8,  kw_continue,         KW_CONTINUE
dq 6,  kw_return,            KW_RETURN
dq 8,  kw_function,         KW_FUNCTION
dq 6,  kw_struct,           KW_STRUCT
dq 5,  kw_class,            KW_CLASS
dq 4,  kw_enum,             KW_ENUM
dq 8,  kw_protocol,         KW_PROTOCOL
dq 9,  kw_extension,        KW_EXTENSION
dq 6,  kw_import,           KW_IMPORT
dq 6,  kw_public,            KW_PUBLIC
dq 7,  kw_private,           KW_PRIVATE
dq 8,  kw_internal,          KW_INTERNAL
dq 11, kw_fileprivate,       KW_FILEPRIVATE
dq 6,  kw_static,            KW_STATIC
dq 5,  kw_final,             KW_FINAL
dq 4,  kw_open,              KW_OPEN
dq 8,  kw_override,          KW_OVERRIDE
dq 4,  kw_init,              KW_INIT
dq 6,  kw_deinit,            KW_DEINIT
dq 4,  kw_self,              KW_SELF
dq 5,  kw_super,              KW_SUPER
dq 4,  kw_true,               KW_TRUE
dq 5,  kw_false,              KW_FALSE
dq 3,  kw_nil,                KW_NIL
dq 2,  kw_as,                 KW_AS
dq 2,  kw_is,                 KW_IS
dq 4,  kw_type,               KW_TYPE
dq 9,  kw_protocols,          KW_PROTOCOLS
dq 7,  kw_generic,            KW_GENERIC
dq 5,  kw_where,              KW_WHERE
dq 10, kw_associated,         KW_ASSOCIATED
dq 8,  kw_requires,           KW_REQUIRES
dq 6,  kw_throws,             KW_THROWS
dq 8,  kw_rethrows,            KW_RETHROWS
dq 3,  kw_try,                KW_TRY
dq 5,  kw_catch,              KW_CATCH
dq 5,  kw_throw,              KW_THROW
dq 5,  kw_defer,              KW_DEFER
dq 5,  kw_guard,              KW_GUARD
dq 6,  kw_switch,             KW_SWITCH
dq 4,  kw_case,               KW_CASE
dq 7,  kw_default,            KW_DEFAULT
dq 11, kw_fallthrough,        KW_FALLTHROUGH
dq 6,  kw_repeat,             KW_REPEAT
dq 5,  kw_match,              KW_MATCH
dq 5,  kw_async,              KW_ASYNC
dq 5,  kw_await,              KW_AWAIT
dq 5,  kw_actor,              KW_ACTOR
dq 4,  kw_task,               KW_TASK
dq 4,  kw_send,               KW_SEND
dq 7,  kw_receive,            KW_RECEIVE
dq 4,  kw_move,               KW_MOVE
dq 4,  kw_copy,               KW_COPY
dq 9,  kw_reference,          KW_REFERENCE
dq 7,  kw_pointer,            KW_POINTER
dq 7,  kw_address,            KW_ADDRESS
dq 11, kw_dereference,        KW_DEREFERENCE
dq 8,  kw_operator,           KW_OPERATOR
dq 10, kw_precedence,         KW_PRECEDENCE
dq 12, kw_associativity,      KW_ASSOCIATIVITY
dq 5,  kw_inout,              KW_INOUT
dq 8,  kw_variadic,           KW_VARIADIC
dq 6,  kw_extern,             KW_EXTERN
dq 6,  kw_inline,             KW_INLINE
dq 8,  kw_volatile,           KW_VOLATILE
dq 6,  kw_unsafe,             KW_UNSAFE
dq 3,  kw_asm,                KW_ASM
dq 6,  kw_sizeof,             KW_SIZEOF
dq 7,  kw_alignof,            KW_ALIGNOF
dq 6,  kw_typeof,             KW_TYPEOF
dq 7,  kw_bitcast,             KW_BITCAST
dq 11, kw_unreachable,        KW_UNREACHABLE
dq 8,  kw_extern_c,            KW_EXTERN_C
dq 9,  kw_namespace,           KW_NAMESPACE
dq 5,  kw_using,               KW_USING
dq 5,  kw_alias,               KW_ALIAS
dq 8,  kw_restrict,            KW_RESTRICT
dq 9,  kw_constexpr,           KW_CONSTEXPR
dq 6,  kw_packed,              KW_PACKED
dq 5,  kw_align,               KW_ALIGN
dq 7,  kw_section,             KW_SECTION
dq 6,  kw_export,              KW_EXPORT
dq 10, kw_import_asm,          KW_IMPORT_ASM
dq 4,  kw_link,                KW_LINK
dq 6,  kw_target,              KW_TARGET
dq 4,  kw_func,                KW_FUNC
dq 3,  kw_get,                 KW_GET
dq 3,  kw_set,                 KW_SET
dq 7,  kw_willset,             KW_WILLSET
dq 6,  kw_didset,              KW_DIDSET
dq 4,  kw_lazy,                KW_LAZY
dq 4,  kw_weak,                KW_WEAK
dq 7,  kw_unowned,             KW_UNOWNED
dq 8,  kw_required,            KW_REQUIRED
dq 12, kw_convenience,         KW_CONVENIENCE
dq 8,  kw_indirect,            KW_INDIRECT
dq 5,  kw_infix,               KW_INFIX
dq 6,  kw_prefix,              KW_PREFIX
dq 7,  kw_postfix,             KW_POSTFIX
dq 15, kw_precedencegroup,     KW_PRECEDENCEGROUP
dq 8,  kw_template,            KW_TEMPLATE
dq 8,  kw_typename,            KW_TYPENAME
dq 7,  kw_concept,             KW_CONCEPT
dq 6,  kw_friend,              KW_FRIEND
dq 7,  kw_virtual,             KW_VIRTUAL
dq 9,  kw_protected,           KW_PROTECTED
dq 6,  kw_delete,              KW_DELETE
dq 3,  kw_new,                 KW_NEW
dq 4,  kw_this,                KW_THIS
dq 7,  kw_nullptr,             KW_NULLPTR
dq 12, kw_static_assert,       KW_STATIC_ASSERT
dq 7,  kw_noexcept,             KW_NOEXCEPT
dq 10, kw_threadlocal,         KW_THREADLOCAL
dq 12, kw_synchronized,        KW_SYNCHRONIZED
dq 5,  kw_yield,               KW_YIELD
dq 8,  kw_typealias,           KW_TYPEALIAS

section .bss

token_buffer:
    resb 4194304