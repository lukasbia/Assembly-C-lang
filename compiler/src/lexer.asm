%include "../include/tokens.inc"

global asc_lexer_init
global asc_lexer_next
global asc_lexer_token_kind
global asc_lexer_token_value

section .data
kw_as: db "as",0
kw_associated: db "associated",0
kw_break: db "break",0
kw_case: db "case",0
kw_catch: db "catch",0
kw_class: db "class",0
kw_continue: db "continue",0
kw_defer: db "defer",0
kw_default: db "default",0
kw_do: db "do",0
kw_else: db "else",0
kw_enum: db "enum",0
kw_extension: db "extension",0
kw_false: db "false",0
kw_final: db "final",0
kw_for: db "for",0
kw_func: db "func",0
kw_if: db "if",0
kw_import: db "import",0
kw_in: db "in",0
kw_init: db "init",0
kw_let: db "let",0
kw_mutating: db "mutating",0
kw_nil: db "nil",0
kw_protocol: db "protocol",0
kw_repeat: db "repeat",0
kw_return: db "return",0
kw_self: db "self",0
kw_static: db "static",0
kw_struct: db "struct",0
kw_subscript: db "subscript",0
kw_super: db "super",0
kw_switch: db "switch",0
kw_throw: db "throw",0
kw_true: db "true",0
kw_try: db "try",0
kw_typealias: db "typealias",0
kw_var: db "var",0
kw_while: db "while",0
kw_where: db "where",0
kw_guard: db "guard",0
kw_open: db "open",0
kw_private: db "private",0
kw_public: db "public",0
kw_internal: db "internal",0
kw_fileprivate: db "fileprivate",0
kw_package: db "package",0
kw_readonly: db "readonly",0
kw_weak: db "weak",0
kw_unowned: db "unowned",0
kw_owned: db "owned",0
kw_move: db "move",0
kw_copy: db "copy",0
kw_inout: db "inout",0
kw_requires: db "requires",0
kw_precedence: db "precedence",0
kw_operator: db "operator",0
kw_prefix: db "prefix",0
kw_postfix: db "postfix",0
kw_infix: db "infix",0
kw_async: db "async",0
kw_await: db "await",0
kw_actor: db "actor",0
kw_sendable: db "sendable",0
kw_isolated: db "isolated",0
kw_nonisolated: db "nonisolated",0
kw_macro: db "macro",0
kw_result: db "result",0
kw_yield: db "yield",0
kw_accessor: db "accessor",0
kw_get: db "get",0
kw_set: db "set",0
kw_willset: db "willset",0
kw_didset: db "didset",0
kw_read: db "read",0
kw_modify: db "modify",0
kw_convenience: db "convenience",0
kw_required: db "required",0
kw_override: db "override",0
kw_dynamic: db "dynamic",0
kw_finalize: db "finalize",0
kw_unsafe: db "unsafe",0
kw_safe: db "safe",0
kw_atomic: db "atomic",0
kw_volatile: db "volatile",0
kw_inline: db "inline",0
kw_noinline: db "noinline",0
kw_extern: db "extern",0
kw_cdecl: db "cdecl",0
kw_system: db "system",0
kw_foreign: db "foreign",0
kw_module: db "module",0
kw_namespace: db "namespace",0
kw_using: db "using",0
kw_include: db "include",0
kw_export: db "export",0
kw_link: db "link",0
kw_target: db "target",0
kw_arch: db "arch",0
kw_cpu: db "cpu",0
kw_abi: db "abi",0
kw_asm: db "asm",0
kw_vol: db "vol",0
kw_byte: db "byte",0
kw_word: db "word",0
kw_dword: db "dword",0
kw_qword: db "qword",0
kw_i8: db "i8",0
kw_i16: db "i16",0
kw_i32: db "i32",0
kw_i64: db "i64",0
kw_u8: db "u8",0
kw_u16: db "u16",0
kw_u32: db "u32",0
kw_u64: db "u64",0
kw_f32: db "f32",0
kw_f64: db "f64",0
kw_bool: db "bool",0
kw_char: db "char",0
kw_string: db "string",0
kw_void: db "void",0
kw_any: db "any",0
kw_never: db "never",0
kw_some: db "some",0
kw_somewhere: db "somewhere",0
kw_throws: db "throws",0
kw_rethrows: db "rethrows",0

section .bss
lexer_ptr: resq 1
lexer_end: resq 1
token_kind: resq 1
token_value: resq 1
number_value: resq 1
ident_buf: resb 256

section .text
asc_lexer_init:
    mov [lexer_ptr], rdi
    mov [lexer_end], rsi
    xor eax, eax
    mov [token_kind], rax
    mov [token_value], rax
    ret

asc_lexer_token_kind:
    mov rax, [token_kind]
    ret

asc_lexer_token_value:
    mov rax, [token_value]
    ret

asc_lexer_next:
    push rbp
    mov rbp, rsp

.skip:
    mov rdi, [lexer_ptr]
    cmp rdi, [lexer_end]
    jae .eof
    mov al, [rdi]
    cmp al, ' '
    je .space
    cmp al, 9
    je .space
    cmp al, 10
    je .space
    cmp al, 13
    je .space
    cmp al, '/'
    jne .not_comment
    cmp rdi, [lexer_end]
    jae .not_comment
    cmp byte [rdi+1], '/'
    jne .not_comment
.comment:
    inc rdi
    inc rdi
    cmp rdi, [lexer_end]
    jae .eof
    cmp byte [rdi], 10
    jne .comment
    mov [lexer_ptr], rdi
    jmp .skip

.space:
    inc rdi
    mov [lexer_ptr], rdi
    jmp .skip

.not_comment:
    cmp al, '0'
    jb .not_number
    cmp al, '9'
    jbe .number

.not_number:
    cmp al, '"'
    je .string
    cmp al, "'"
    je .char

    cmp al, 'A'
    jb .ident_lower
    cmp al, 'Z'
    ja .ident_lower
    jmp .ident

.ident_lower:
    cmp al, '_'
    je .ident
    cmp al, 'a'
    jb .operator
    cmp al, 'z'
    ja .operator

.ident:
    mov r8, rdi
    xor rcx, rcx
.ident_loop:
    cmp rdi, [lexer_end]
    jae .ident_done
    mov al, [rdi]
    cmp al, 'A'
    jb .ident_check_lower
    cmp al, 'Z'
    jbe .ident_take
.ident_check_lower:
    cmp al, 'a'
    jb .ident_check_digit
    cmp al, 'z'
    jbe .ident_take
.ident_check_digit:
    cmp al, '0'
    jb .ident_check_us
    cmp al, '9'
    jbe .ident_take
.ident_check_us:
    cmp al, '_'
    jne .ident_done
.ident_take:
    cmp rcx, 255
    jae .ident_done
    mov [ident_buf+rcx], al
    inc rcx
    inc rdi
    jmp .ident_loop
.ident_done:
    mov byte [ident_buf+rcx], 0
    mov [lexer_ptr], rdi
    lea rsi, [ident_buf]
    call asc_keyword_lookup
    test eax, eax
    jnz .keyword
    mov qword [token_kind], TOK_IDENT
    lea rax, [ident_buf]
    mov [token_value], rax
    jmp .done

.keyword:
    mov [token_kind], rax
    lea rax, [ident_buf]
    mov [token_value], rax
    jmp .done

.number:
    xor rax, rax
.num_loop:
    cmp rdi, [lexer_end]
    jae .num_done
    mov dl, [rdi]
    cmp dl, '0'
    jb .num_done
    cmp dl, '9'
    ja .num_done
    imul rax, rax, 10
    sub dl, '0'
    movzx rdx, dl
    add rax, rdx
    inc rdi
    jmp .num_loop
.num_done:
    mov [lexer_ptr], rdi
    mov [number_value], rax
    mov qword [token_kind], TOK_INT
    mov [token_value], rax
    jmp .done

.string:
    inc rdi
    mov r8, rdi
    xor rcx, rcx
.str_loop:
    cmp rdi, [lexer_end]
    jae .lex_error
    mov al, [rdi]
    cmp al, '"'
    je .str_done
    cmp rcx, 255
    jae .lex_error
    mov [ident_buf+rcx], al
    inc rcx
    inc rdi
    jmp .str_loop
.str_done:
    mov byte [ident_buf+rcx], 0
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_STRING
    lea rax, [ident_buf]
    mov [token_value], rax
    jmp .done

.char:
    inc rdi
    cmp rdi, [lexer_end]
    jae .lex_error
    movzx eax, byte [rdi]
    inc rdi
    cmp rdi, [lexer_end]
    jae .lex_error
    cmp byte [rdi], "'"
    jne .lex_error
    inc rdi
    mov [lexer_ptr], rdi
    mov [token_value], rax
    mov qword [token_kind], TOK_CHAR
    jmp .done

.operator:
    cmp al, '+'
    je .one_plus
    cmp al, '-'
    je .minus
    cmp al, '*'
    je .one_star
    cmp al, '/'
    je .one_slash
    cmp al, '%'
    je .one_percent
    cmp al, '='
    je .equals
    cmp al, '!'
    je .bang
    cmp al, '<'
    je .less
    cmp al, '>'
    je .greater
    cmp al, '&'
    je .amp
    cmp al, '|'
    je .pipe
    cmp al, '('
    je .simple_lp
    cmp al, ')'
    je .simple_rp
    cmp al, '{'
    je .simple_lb
    cmp al, '}'
    je .simple_rb
    cmp al, '['
    je .simple_lbr
    cmp al, ']'
    je .simple_rbr
    cmp al, ':'
    je .simple_colon
    cmp al, ','
    je .simple_comma
    cmp al, '.'
    je .simple_dot
    cmp al, ';'
    je .simple_semi
    jmp .lex_error

.one_plus:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_PLUS
    jmp .done
.minus:
    inc rdi
    cmp rdi, [lexer_end]
    jae .minus_only
    cmp byte [rdi], '>'
    jne .minus_only
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_ARROW
    jmp .done
.minus_only:
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_MINUS
    jmp .done
.one_star:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_STAR
    jmp .done
.one_slash:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_SLASH
    jmp .done
.one_percent:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_PERCENT
    jmp .done
.equals:
    inc rdi
    cmp rdi, [lexer_end]
    jae .assign
    cmp byte [rdi], '='
    jne .assign
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_EQ
    jmp .done
.assign:
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_ASSIGN
    jmp .done
.bang:
    inc rdi
    cmp rdi, [lexer_end]
    jae .not_only
    cmp byte [rdi], '='
    jne .not_only
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_NE
    jmp .done
.not_only:
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_NOT
    jmp .done
.less:
    inc rdi
    cmp rdi, [lexer_end]
    jae .less_only
    cmp byte [rdi], '='
    je .le
    cmp byte [rdi], '<'
    je .shl
.less_only:
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_LT
    jmp .done
.le:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_LE
    jmp .done
.shl:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_SHL
    jmp .done
.greater:
    inc rdi
    cmp rdi, [lexer_end]
    jae .greater_only
    cmp byte [rdi], '='
    je .ge
    cmp byte [rdi], '>'
    je .shr
.greater_only:
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_GT
    jmp .done
.ge:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_GE
    jmp .done
.shr:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_SHR
    jmp .done
.amp:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_BITAND
    jmp .done
.pipe:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_BITOR
    jmp .done

.simple_lp:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_LPAREN
    jmp .done
.simple_rp:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_RPAREN
    jmp .done
.simple_lb:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_LBRACE
    jmp .done
.simple_rb:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_RBRACE
    jmp .done
.simple_lbr:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_LBRACKET
    jmp .done
.simple_rbr:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_RBRACKET
    jmp .done
.simple_colon:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_COLON
    jmp .done
.simple_comma:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_COMMA
    jmp .done
.simple_dot:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_DOT
    jmp .done
.simple_semi:
    inc rdi
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_SEMI
    jmp .done

.eof:
    mov [lexer_ptr], rdi
    mov qword [token_kind], TOK_EOF
    xor eax, eax
    mov [token_value], rax
    jmp .done

.lex_error:
    mov qword [token_kind], -1
    mov qword [token_value], 0

.done:
    mov rax, [token_kind]
    pop rbp
    ret

asc_keyword_lookup:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rbx, rsi
    lea rsi, [kw_table]
.loop:
    mov rdi, [rsi]
    test rdi, rdi
    jz .no
    mov rdx, rbx
    mov rcx, rdi
.cmp:
    mov al, [rdx]
    mov ah, [rcx]
    cmp al, ah
    jne .next
    test al, al
    jz .match
    inc rdx
    inc rcx
    jmp .cmp
.next:
    add rsi, 16
    jmp .loop
.match:
    mov eax, [rsi+8]
    jmp .out
.no:
    xor eax, eax
.out:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

section .data
kw_table:
    dq kw_as,          KW_AS
    dq kw_associated,  KW_ASSOCIATED
    dq kw_break,       KW_BREAK
    dq kw_case,        KW_CASE
    dq kw_catch,       KW_CATCH
    dq kw_class,       KW_CLASS
    dq kw_continue,    KW_CONTINUE
    dq kw_defer,       KW_DEFER
    dq kw_default,     KW_DEFAULT
    dq kw_do,          KW_DO
    dq kw_else,        KW_ELSE
    dq kw_enum,        KW_ENUM
    dq kw_extension,   KW_EXTENSION
    dq kw_false,       KW_FALSE
    dq kw_final,       KW_FINAL
    dq kw_for,         KW_FOR
    dq kw_func,        KW_FUNC
    dq kw_if,          KW_IF
    dq kw_import,      KW_IMPORT
    dq kw_in,          KW_IN
    dq kw_init,        KW_INIT
    dq kw_let,         KW_LET
    dq kw_mutating,    KW_MUTATING
    dq kw_nil,         KW_NIL
    dq kw_protocol,    KW_PROTOCOL
    dq kw_repeat,      KW_REPEAT
    dq kw_return,      KW_RETURN
    dq kw_self,        KW_SELF
    dq kw_static,      KW_STATIC
    dq kw_struct,      KW_STRUCT
    dq kw_subscript,   KW_SUBSCRIPT
    dq kw_super,       KW_SUPER
    dq kw_switch,      KW_SWITCH
    dq kw_throw,       KW_THROW
    dq kw_true,        KW_TRUE
    dq kw_try,         KW_TRY
    dq kw_typealias,   KW_TYPEALIAS
    dq kw_var,         KW_VAR
    dq kw_while,       KW_WHILE
    dq kw_where,       KW_WHERE
    dq kw_guard,       KW_GUARD
    dq kw_open,        KW_OPEN
    dq kw_private,     KW_PRIVATE
    dq kw_public,      KW_PUBLIC
    dq kw_internal,    KW_INTERNAL
    dq kw_fileprivate, KW_FILEPRIVATE
    dq kw_package,     KW_PACKAGE
    dq kw_readonly,    KW_READONLY
    dq kw_weak,        KW_WEAK
    dq kw_unowned,     KW_UNOWNED
    dq kw_owned,       KW_OWNED
    dq kw_move,        KW_MOVE
    dq kw_copy,        KW_COPY
    dq kw_inout,       KW_INOUT
    dq kw_requires,    KW_REQUIRES
    dq kw_precedence,  KW_PRECEDENCE
    dq kw_operator,    KW_OPERATOR
    dq kw_prefix,      KW_PREFIX
    dq kw_postfix,     KW_POSTFIX
    dq kw_infix,       KW_INFIX
    dq kw_async,       KW_ASYNC
    dq kw_await,       KW_AWAIT
    dq kw_actor,       KW_ACTOR
    dq kw_sendable,    KW_SENDABLE
    dq kw_isolated,    KW_ISOLATED
    dq kw_nonisolated, KW_NONISOLATED
    dq kw_macro,       KW_MACRO
    dq kw_result,      KW_RESULT
    dq kw_yield,       KW_YIELD
    dq kw_accessor,    KW_ACCESSOR
    dq kw_get,         KW_GET
    dq kw_set,         KW_SET
    dq kw_willset,     KW_WILLSET
    dq kw_didset,      KW_DIDSET
    dq kw_read,        KW_READ
    dq kw_modify,      KW_MODIFY
    dq kw_convenience, KW_CONVENIENCE
    dq kw_required,    KW_REQUIRED
    dq kw_override,    KW_OVERRIDE
    dq kw_dynamic,     KW_DYNAMIC
    dq kw_finalize,    KW_FINALIZE
    dq kw_unsafe,      KW_UNSAFE
    dq kw_safe,        KW_SAFE
    dq kw_atomic,      KW_ATOMIC
    dq kw_volatile,    KW_VOLATILE
    dq kw_inline,      KW_INLINE
    dq kw_noinline,    KW_NOINLINE
    dq kw_extern,      KW_EXTERN
    dq kw_cdecl,       KW_CDECL
    dq kw_system,      KW_SYSTEM
    dq kw_foreign,     KW_FOREIGN
    dq kw_module,      KW_MODULE
    dq kw_namespace,   KW_NAMESPACE
    dq kw_using,       KW_USING
    dq kw_include,     KW_INCLUDE
    dq kw_export,      KW_EXPORT
    dq kw_link,        KW_LINK
    dq kw_target,      KW_TARGET
    dq kw_arch,        KW_ARCH
    dq kw_cpu,         KW_CPU
    dq kw_abi,         KW_ABI
    dq kw_asm,         KW_ASM
    dq kw_vol,         KW_VOL
    dq kw_byte,        KW_BYTE
    dq kw_word,        KW_WORD
    dq kw_dword,       KW_DWORD
    dq kw_qword,       KW_QWORD
    dq kw_i8,          KW_I8
    dq kw_i16,         KW_I16
    dq kw_i32,         KW_I32
    dq kw_i64,         KW_I64
    dq kw_u8,           KW_U8
    dq kw_u16,          KW_U16
    dq kw_u32,          KW_U32
    dq kw_u64,          KW_U64
    dq kw_f32,          KW_F32
    dq kw_f64,          KW_F64
    dq kw_bool,         KW_BOOL
    dq kw_char,         KW_CHAR
    dq kw_string,       KW_STRING
    dq kw_void,         KW_VOID
    dq kw_any,          KW_ANY
    dq kw_never,        KW_NEVER
    dq kw_some,         KW_SOME
    dq kw_somewhere,    KW_SOMEWHERE
    dq kw_throws,       KW_THROWS
    dq kw_rethrows,     KW_RETHROWS
    dq 0, 0
