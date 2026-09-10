section .data

error_text db 'ASC parser error',10
error_text_len equ $-error_text

section .bss

current_token resq 1
current_type resq 1

section .text

global _start
global parser_entry

extern lexer_tokenize
extern token_types
extern token_values
extern token_count

_start:

    call parser_entry

    mov rdi,rax
    mov rax,60
    syscall

parser_entry:

    call lexer_tokenize

    mov qword [current_token],0

    call parse_program

    ret

parse_program:

.loop:

    mov rax,[current_token]
    mov rbx,[token_count]

    cmp rax,rbx
    jae .success

    call current_type_load

    cmp rax,0
    je .success

    cmp rax,1
    jne .fail

    call parse_section

    test rax,rax
    jz .fail

    jmp .loop

.success:

    mov rax,0
    ret

.fail:

    call parser_error

    mov rax,1
    ret

parse_section:

    call expect_keyword_section

    test rax,rax
    jz .fail

    call expect_identifier

    test rax,rax
    jz .fail

    call expect_left_brace

    test rax,rax
    jz .fail

.body:

    call current_type_load

    cmp rax,6
    je .end

    cmp rax,0
    je .fail

    call parse_section_statement

    test rax,rax
    jz .fail

    jmp .body

.end:

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_section_statement:

    call current_type_load

    cmp rax,1
    je .keyword_statement

    cmp rax,2
    je .identifier_statement

    cmp rax,6
    je .success

    xor rax,rax
    ret

.keyword_statement:

    call parse_keyword_statement
    ret

.identifier_statement:

    call parse_identifier_statement
    ret

.success:

    mov rax,1
    ret

parse_keyword_statement:

    call token_value_load

    mov rdi,kw_main
    call string_equal

    jc .main

    mov rdi,kw_define
    call string_equal

    jc .define

    mov rdi,kw_return
    call string_equal

    jc .return

    mov rdi,kw_write
    call string_equal

    jc .operation

    mov rdi,kw_exit
    call string_equal

    jc .operation

    mov rdi,kw_load
    call string_equal

    jc .operation

    mov rdi,kw_store
    call string_equal

    jc .operation

    mov rdi,kw_compare
    call string_equal

    jc .operation

    mov rdi,kw_jump
    call string_equal

    jc .operation

    mov rdi,kw_call
    call string_equal

    jc .operation

    xor rax,rax
    ret

.main:

    call parse_named_block
    ret

.define:

    call parse_definition
    ret

.return:

    call advance

    mov rax,1
    ret

.operation:

    call parse_operation
    ret

parse_identifier_statement:

    call save_current_token

    call advance

    call current_type_load

    cmp rax,11
    je .assignment

    cmp rax,7
    je .operation

    cmp rax,9
    je .function_call

    cmp rax,6
    je .block

    xor rax,rax
    ret

.assignment:

    call parse_assignment
    ret

.operation:

    call parse_operation_after_name
    ret

.function_call:

    call parse_function_call_after_name
    ret

.block:

    call parse_block
    ret

parse_assignment:

    call advance

    call expect_left_paren

    test rax,rax
    jz .fail

    call parse_value

    test rax,rax
    jz .fail

    call expect_right_paren

    test rax,rax
    jz .fail

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_operation:

    call advance

    call parse_operation_arguments

    ret

parse_operation_after_name:

    call parse_operation_arguments
    ret

parse_operation_arguments:

    call expect_left_paren

    test rax,rax
    jz .fail

    call parse_arguments_until_right_paren

    test rax,rax
    jz .fail

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_function_call_after_name:

    call expect_left_angle

    test rax,rax
    jz .fail

    call parse_arguments_until_right_angle

    test rax,rax
    jz .fail

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_named_block:

    call advance

    call expect_left_brace

    test rax,rax
    jz .fail

    call parse_block

    ret

.fail:

    xor rax,rax
    ret

parse_definition:

    call advance

    call current_type_load

    cmp rax,1
    je .keyword

    cmp rax,2
    je .identifier

    xor rax,rax
    ret

.keyword:

    call token_value_load

    mov rdi,kw_function
    call string_equal

    jc .function

    mov rdi,kw_structure
    call string_equal

    jc .structure

    xor rax,rax
    ret

.function:

    call advance

    call expect_identifier

    test rax,rax
    jz .fail

    call expect_left_angle

    test rax,rax
    jz .fail

    call parse_arguments_until_right_angle

    test rax,rax
    jz .fail

    call expect_left_brace

    test rax,rax
    jz .fail

    call parse_block

    ret

.structure:

    call advance

    call expect_identifier

    test rax,rax
    jz .fail

    call expect_left_brace

    test rax,rax
    jz .fail

    call parse_structure_body

    ret

.fail:

    xor rax,rax
    ret

parse_structure_body:

.loop:

    call current_type_load

    cmp rax,6
    je .end

    cmp rax,0
    je .fail

    call parse_structure_property

    test rax,rax
    jz .fail

    jmp .loop

.end:

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_structure_property:

    call current_type_load

    cmp rax,1
    jne .fail

    call token_value_load

    mov rdi,kw_define
    call string_equal

    jc .define

    xor rax,rax
    ret

.define:

    call advance

    call current_type_load

    cmp rax,1
    jne .fail

    call token_value_load

    mov rdi,kw_immutable
    call string_equal

    jc .property

    mov rdi,kw_mutable
    call string_equal

    jc .property

    xor rax,rax
    ret

.property:

    call advance

    call token_value_load

    mov rdi,kw_property
    call string_equal

    jc .property_name

    xor rax,rax
    ret

.property_name:

    call advance

    call expect_identifier

    test rax,rax
    jz .fail

    call expect_colon

    test rax,rax
    jz .fail

    call expect_identifier

    test rax,rax
    jz .fail

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_block:

.loop:

    call current_type_load

    cmp rax,6
    je .end

    cmp rax,0
    je .fail

    call parse_section_statement

    test rax,rax
    jz .fail

    jmp .loop

.end:

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_arguments_until_right_paren:

.loop:

    call current_type_load

    cmp rax,8
    je .end

    cmp rax,0
    je .fail

    call parse_value

    test rax,rax
    jz .fail

    call current_type_load

    cmp rax,13
    je .comma

    cmp rax,8
    je .end

    jmp .fail

.comma:

    call advance
    jmp .loop

.end:

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_arguments_until_right_angle:

.loop:

    call current_type_load

    cmp rax,10
    je .end

    cmp rax,0
    je .fail

    call parse_value

    test rax,rax
    jz .fail

    call current_type_load

    cmp rax,13
    je .comma

    cmp rax,10
    je .end

    jmp .fail

.comma:

    call advance
    jmp .loop

.end:

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

parse_value:

    call current_type_load

    cmp rax,2
    je .identifier

    cmp rax,3
    je .number

    cmp rax,4
    je .string

    cmp rax,1
    je .keyword

    xor rax,rax
    ret

.identifier:

    call advance
    mov rax,1
    ret

.number:

    call advance
    mov rax,1
    ret

.string:

    call advance
    mov rax,1
    ret

.keyword:

    call token_value_load

    mov rdi,kw_true
    call string_equal

    jc .boolean

    mov rdi,kw_false
    call string_equal

    jc .boolean

    mov rdi,kw_null
    call string_equal

    jc .null

    xor rax,rax
    ret

.boolean:

    call advance
    mov rax,1
    ret

.null:

    call advance
    mov rax,1
    ret

expect_keyword_section:

    call current_type_load

    cmp rax,1
    jne .fail

    call token_value_load

    mov rdi,kw_section
    call string_equal

    jc .ok

.fail:

    xor rax,rax
    ret

.ok:

    call advance

    mov rax,1
    ret

expect_identifier:

    call current_type_load

    cmp rax,2
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

expect_left_brace:

    call current_type_load

    cmp rax,5
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

expect_right_brace:

    call current_type_load

    cmp rax,6
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

expect_left_paren:

    call current_type_load

    cmp rax,7
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

expect_right_paren:

    call current_type_load

    cmp rax,8
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

expect_left_angle:

    call current_type_load

    cmp rax,9
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

expect_colon:

    call current_type_load

    cmp rax,12
    jne .fail

    call advance

    mov rax,1
    ret

.fail:

    xor rax,rax
    ret

save_current_token:

    mov rax,[current_token]
    ret

advance:

    mov rax,[current_token]
    inc rax
    mov [current_token],rax
    ret

current_type_load:

    mov rax,[current_token]
    mov rax,[token_types+rax*8]
    mov [current_type],rax
    ret

token_value_load:

    mov rax,[current_token]
    mov rax,[token_values+rax*8]
    ret

string_equal:

    push rsi
    push rdi
    push rax

.loop:

    mov al,[rsi]

    cmp al,[rdi]
    jne .no

    test al,al
    jz .yes

    inc rsi
    inc rdi

    jmp .loop

.yes:

    pop rax
    pop rdi
    pop rsi

    stc
    ret

.no:

    pop rax
    pop rdi
    pop rsi

    clc
    ret

parser_error:

    mov rax,1
    mov rdi,2
    mov rsi,error_text
    mov rdx,error_text_len
    syscall

    ret

kw_section db 'section',0
kw_main db 'main',0
kw_define db 'define',0
kw_function db 'function',0
kw_structure db 'structure',0
kw_immutable db 'immutable',0
kw_mutable db 'mutable',0
kw_property db 'property',0
kw_return db 'return',0
kw_write db 'write.value.to.output',0
kw_exit db 'exit.program',0
kw_load db 'load',0
kw_store db 'store',0
kw_compare db 'compare',0
kw_jump db 'jump',0
kw_call db 'call',0
kw_true db 'true',0
kw_false db 'false',0
kw_null db 'null',0