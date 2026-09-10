bits 64

global asc_lexer

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

%define TOKEN_SIZE         32
%define MAX_TOKENS         1048576

%define KW_VAR             1
%define KW_LET             2
%define KW_FUNC            3
%define KW_FUNCTION        4
%define KW_IF              5
%define KW_ELSE            6
%define KW_WHILE           7
%define KW_DO              8
%define KW_FOR              9
%define KW_IN              10
%define KW_RETURN          11
%define KW_BREAK           12
%define KW_CONTINUE        13
%define KW_TRUE             14
%define KW_FALSE            15
%define KW_NIL              16
%define KW_STRUCT           17
%define KW_CLASS            18
%define KW_ENUM             19
%define KW_PROTOCOL         20
%define KW_EXTENSION        21
%define KW_IMPORT           22
%define KW_PUBLIC           23
%define KW_PRIVATE          24
%define KW_INTERNAL         25
%define KW_STATIC           26
%define KW_FINAL            27
%define KW_OPEN             28
%define KW_OVERRIDE         29
%define KW_INIT             30
%define KW_DEINIT           31
%define KW_SELF             32
%define KW_SUPER            33
%define KW_AS               34
%define KW_IS               35
%define KW_TYPE             36
%define KW_WHERE            37
%define KW_THROWS           38
%define KW_RETHROWS         39
%define KW_TRY              40
%define KW_CATCH            41
%define KW_THROW            42
%define KW_DEFER            43
%define KW_GUARD            44
%define KW_SWITCH            45
%define KW_CASE             46
%define KW_DEFAULT          47
%define KW_FALLTHROUGH      48
%define KW_REPEAT           49
%define KW_MATCH            50
%define KW_ASYNC            51
%define KW_AWAIT            52
%define KW_ACTOR            53
%define KW_TASK             54
%define KW_SEND             55
%define KW_RECEIVE          56
%define KW_MOVE             57
%define KW_COPY             58
%define KW_REFERENCE        59
%define KW_POINTER          60
%define KW_ADDRESS          61
%define KW_DEREFERENCE      62
%define KW_OPERATOR         63
%define KW_PRECEDENCE       64
%define KW_ASSOCIATIVITY    65
%define KW_INOUT            66
%define KW_VARIADIC         67
%define KW_EXTERN           68
%define KW_INLINE           69
%define KW_VOLATILE         70
%define KW_UNSAFE           71
%define KW_ASM              72
%define KW_SIZEOF           73
%define KW_ALIGNOF          74
%define KW_TYPEOF           75
%define KW_BITCAST          76
%define KW_UNREACHABLE      77
%define KW_NAMESPACE        78
%define KW_USING            79
%define KW_ALIAS            80
%define KW_RESTRICT         81
%define KW_CONSTEXPR        82
%define KW_PACKED           83
%define KW_ALIGN            84
%define KW_SECTION          85
%define KW_EXPORT           86
%define KW_LINK             87
%define KW_TARGET           88
%define KW_GET              89
%define KW_SET              90
%define KW_WILLSET          91
%define KW_DIDSET           92
%define KW_LAZY             93
%define KW_WEAK             94
%define KW_UNOWNED          95
%define KW_REQUIRED         96
%define KW_CONVENIENCE      97
%define KW_INDIRECT         98
%define KW_INFIX            99
%define KW_PREFIX           100
%define KW_POSTFIX          101
%define KW_PRECEDENCEGROUP  102
%define KW_TEMPLATE         103
%define KW_TYPENAME         104
%define KW_CONCEPT          105
%define KW_FRIEND           106
%define KW_VIRTUAL          107
%define KW_PROTECTED        108
%define KW_DELETE           109
%define KW_NEW              110
%define KW_THIS             111
%define KW_NULLPTR          112
%define KW_STATIC_ASSERT    113
%define KW_NOEXCEPT         114
%define KW_THREADLOCAL      115
%define KW_SYNCHRONIZED     116
%define KW_YIELD            117
%define KW_TYPEALIAS        118
%define KW_OPTIONAL         119
%define KW_NONMUTATING      120
%define KW_MUTATING         121
%define KW_CONSUMING        122
%define KW_BORROWING        123
%define KW_ISOLATED         124
%define KW_NONISOLATED      125
%define KW_ACTIVATED        126
%define KW_END              127

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
%define OP_ARROW            23
%define OP_RANGE            24
%define OP_OPTIONAL         25
%define OP_COALESCE         26
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
%define P_QUESTION          11
%define P_AT                12

section .text

asc_lexer:

    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    mov rdi, MAX_TOKENS * TOKEN_SIZE
    call malloc

    test rax, rax
    jz .fail

    mov r14, rax
    xor r15d, r15d
    xor ebx, ebx

.loop:

    cmp rbx, r13
    jae .eof

    mov al, [r12 + rbx]

    cmp al, ' '
    je .space

    cmp al, 9
    je .space

    cmp al, 10
    je .newline

    cmp al, 13
    je .newline

    cmp al, '"'
    je .string

    cmp al, 39
    je .character

    cmp al, '0'
    jb .not_number

    cmp al, '9'
    jbe .number

.not_number:

    call is_identifier_start
    jc .identifier

    jmp .operator

.space:

    inc rbx
    jmp .loop

.newline:

    inc rbx
    jmp .loop

.identifier:

    mov r8, rbx

.identifier_loop:

    cmp rbx, r13
    jae .identifier_done

    mov al, [r12 + rbx]

    call is_identifier_continue
    jnc .identifier_done

    inc rbx
    jmp .identifier_loop

.identifier_done:

    mov r9, rbx

    mov rdi, r12
    add rdi, r8
    mov rsi, r9
    sub rsi, r8

    call keyword_lookup

    test eax, eax
    jz .identifier_token

    mov r10d, eax
    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_KEYWORD
    mov dword [rdi + 4], r10d
    mov qword [rdi + 8], r8
    mov qword [rdi + 16], r9

    inc r15
    jmp .loop

.identifier_token:

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_IDENTIFIER
    mov qword [rdi + 8], r8
    mov qword [rdi + 16], r9

    inc r15
    jmp .loop

.number:

    mov r8, rbx

.number_loop:

    cmp rbx, r13
    jae .number_done

    mov al, [r12 + rbx]

    cmp al, '0'
    jb .number_done

    cmp al, '9'
    ja .number_done

    inc rbx
    jmp .number_loop

.number_done:

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_INTEGER
    mov qword [rdi + 8], r8
    mov qword [rdi + 16], rbx

    inc r15
    jmp .loop

.string:

    inc rbx
    mov r8, rbx

.string_loop:

    cmp rbx, r13
    jae .fail

    mov al, [r12 + rbx]

    cmp al, '"'
    je .string_done

    inc rbx
    jmp .string_loop

.string_done:

    mov r9, rbx
    inc rbx

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_STRING
    mov qword [rdi + 8], r8
    mov qword [rdi + 16], r9

    inc r15
    jmp .loop

.character:

    inc rbx
    mov r8, rbx

    cmp rbx, r13
    jae .fail

    inc rbx

    cmp rbx, r13
    jae .fail

    cmp byte [r12 + rbx], 39
    jne .fail

    mov r9, rbx
    inc rbx

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_CHARACTER
    mov qword [rdi + 8], r8
    mov qword [rdi + 16], r9

    inc r15
    jmp .loop

.operator:

    mov r8d, OP_ASSIGN
    mov r9d, 1

    cmp al, '+'
    jne .op_minus
    mov r8d, OP_PLUS
    jmp .operator_check

.op_minus:

    cmp al, '-'
    jne .op_mul
    mov r8d, OP_MINUS
    jmp .operator_check

.op_mul:

    cmp al, '*'
    jne .op_div
    mov r8d, OP_MUL
    jmp .operator_check

.op_div:

    cmp al, '/'
    jne .op_mod
    mov r8d, OP_DIV
    jmp .operator_check

.op_mod:

    cmp al, '%'
    jne .op_eq
    mov r8d, OP_MOD
    jmp .operator_check

.op_eq:

    cmp al, '='
    jne .op_not
    mov r8d, OP_ASSIGN
    jmp .two_char

.op_not:

    cmp al, '!'
    jne .op_lt
    mov r8d, OP_NOT
    jmp .two_char

.op_lt:

    cmp al, '<'
    jne .op_gt
    mov r8d, OP_LT
    jmp .two_char

.op_gt:

    cmp al, '>'
    jne .op_and
    mov r8d, OP_GT
    jmp .two_char

.op_and:

    cmp al, '&'
    jne .op_or
    mov r8d, OP_BITAND
    jmp .operator_check

.op_or:

    cmp al, '|'
    jne .punctuation
    mov r8d, OP_BITOR
    jmp .operator_check

.two_char:

    cmp rbx, r13
    jae .operator_check

    mov al, [r12 + rbx + 1]

    cmp al, '='
    jne .operator_check

    cmp r8d, OP_ASSIGN
    jne .not_eq

    mov r8d, OP_EQ
    jmp .two_char_done

.not_eq:

    cmp r8d, OP_NOT
    jne .le

    mov r8d, OP_NE
    jmp .two_char_done

.le:

    cmp r8d, OP_LT
    jne .ge

    mov r8d, OP_LE
    jmp .two_char_done

.ge:

    cmp r8d, OP_GT
    jne .two_char_done

    mov r8d, OP_GE

.two_char_done:

    add r9d, 1

.operator_check:

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_OPERATOR
    mov dword [rdi + 4], r8d
    mov qword [rdi + 8], rbx
    mov rax, rbx
    add rax, r9
    mov qword [rdi + 16], rax

    add rbx, r9
    inc r15
    jmp .loop

.punctuation:

    mov r8d, 0

    cmp al, '('
    jne .pc
    mov r8d, P_OPEN
    jmp .punct_done

.pc:
    cmp al, ')'
    jne .plb
    mov r8d, P_CLOSE
    jmp .punct_done

.plb:
    cmp al, '['
    jne .prb
    mov r8d, P_LBRACKET
    jmp .punct_done

.prb:
    cmp al, ']'
    jne .plbrace
    mov r8d, P_RBRACKET
    jmp .punct_done

.plbrace:
    cmp al, '{'
    jne .prbrace
    mov r8d, P_LBRACE
    jmp .punct_done

.prbrace:
    cmp al, '}'
    jne .comma
    mov r8d, P_RBRACE
    jmp .punct_done

.comma:
    cmp al, ','
    jne .colon
    mov r8d, P_COMMA
    jmp .punct_done

.colon:
    cmp al, ':'
    jne .semi
    mov r8d, P_COLON
    jmp .punct_done

.semi:
    cmp al, ';'
    jne .dot
    mov r8d, P_SEMICOLON
    jmp .punct_done

.dot:
    cmp al, '.'
    jne .question
    mov r8d, P_DOT
    jmp .punct_done

.question:
    cmp al, '?'
    jne .at
    mov r8d, P_QUESTION
    jmp .punct_done

.at:
    cmp al, '@'
    jne .fail
    mov r8d, P_AT

.punct_done:

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_PUNCTUATION
    mov dword [rdi + 4], r8d
    mov qword [rdi + 8], rbx
    lea rax, [rbx + 1]
    mov qword [rdi + 16], rax

    inc rbx
    inc r15
    jmp .loop

.eof:

    mov rdi, r14
    imul rax, r15, TOKEN_SIZE
    add rdi, rax

    mov dword [rdi], TOKEN_EOF
    mov qword [rdi + 8], rbx
    mov qword [rdi + 16], rbx

    mov rax, r14
    mov rdx, r15
    inc rdx

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

.fail:

    xor eax, eax
    xor edx, edx

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


is_identifier_start:

    cmp al, '_'
    je .yes

    cmp al, 'A'
    jb .no

    cmp al, 'Z'
    jbe .yes

    cmp al, 'a'
    jb .no

    cmp al, 'z'
    jbe .yes

.no:
    clc
    ret

.yes:
    stc
    ret


is_identifier_continue:

    call is_identifier_start
    jc .yes

    cmp al, '0'
    jb .no

    cmp al, '9'
    ja .no

.yes:
    stc
    ret

.no:
    clc
    ret


keyword_lookup:

    cmp rsi, 2
    jne .k3

    cmp byte [rdi], 'v'
    jne .let

    cmp byte [rdi + 1], 'a'
    jne .let

    cmp byte [rdi + 2], 'r'
    je .var

.let:
    cmp byte [rdi], 'l'
    jne .false

    cmp byte [rdi + 1], 'e'
    jne .false

    cmp byte [rdi + 2], 't'
    jne .false

.var:
    mov eax, KW_VAR
    ret

.k3:

    cmp rsi, 3
    jne .k4

    cmp dword [rdi], 'f'
    jne .if

    cmp byte [rdi + 1], 'u'
    jne .if

    cmp byte [rdi + 2], 'n'
    je .func

.if:
    cmp byte [rdi], 'i'
    jne .else

    cmp byte [rdi + 1], 'f'
    je .kw_if

.else:
    cmp byte [rdi], 'f'
    jne .nil

    cmp byte [rdi + 1], 'o'
    jne .nil

    cmp byte [rdi + 2], 'r'
    je .for

.nil:
    cmp byte [rdi], 'n'
    jne .false

    cmp byte [rdi + 1], 'i'
    jne .false

    cmp byte [rdi + 2], 'l'
    je .nil_kw

.false:
    cmp byte [rdi], 'd'
    jne .false2

    cmp byte [rdi + 1], 'o'
    jne .false2

    cmp byte [rdi + 2], 'e'
    jne .false2

    mov eax, KW_DO
    ret

.false2:
    xor eax, eax
    ret

.func:
    mov eax, KW_FUNC
    ret

.kw_if:
    mov eax, KW_IF
    ret

.for:
    mov eax, KW_FOR
    ret

.nil_kw:
    mov eax, KW_NIL
    ret

.k4:

    cmp rsi, 4
    jne .k5

    cmp byte [rdi], 'e'
    jne .true

    cmp byte [rdi + 1], 'l'
    jne .true

    cmp byte [rdi + 2], 's'
    jne .true

    cmp byte [rdi + 3], 'e'
    je .kw_else

.true:
    cmp dword [rdi], 'true'
    je .kw_true

    xor eax, eax
    ret

.kw_else:
    mov eax, KW_ELSE
    ret

.kw_true:
    mov eax, KW_TRUE
    ret

.k5:

    cmp rsi, 5
    jne .k6

    cmp dword [rdi], 'while'
    je .kw_while

    cmp dword [rdi], 'break'
    je .kw_break

    xor eax, eax
    ret

.kw_while:
    mov eax, KW_WHILE
    ret

.kw_break:
    mov eax, KW_BREAK
    ret

.k6:

    cmp dword [rdi], 'return'
    je .kw_return

    cmp dword [rdi], 'struct'
    je .kw_struct

    cmp dword [rdi], 'import'
    je .kw_import

    xor eax, eax
    ret

.kw_return:
    mov eax, KW_RETURN
    ret

.kw_struct:
    mov eax, KW_STRUCT
    ret

.kw_import:
    mov eax, KW_IMPORT
    ret