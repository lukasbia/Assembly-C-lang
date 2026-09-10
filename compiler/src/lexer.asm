section .data

source db 'section .data {',10
       db 'message = ("Hello, world!")',10
       db 'account.balance = (1000)',10
       db '}',10
       db 'section .text {',10
       db 'main {',10
       db 'write.value.to.output (message)',10
       db 'exit.program (0)',10
       db '}',10
       db '}',10
       db 0

kw_section db 'section',0
kw_main db 'main',0
kw_define db 'define',0
kw_function db 'function',0
kw_structure db 'structure',0
kw_immutable db 'immutable',0
kw_mutable db 'mutable',0
kw_property db 'property',0
kw_variable db 'variable',0
kw_return db 'return',0
kw_if db 'if',0
kw_else db 'else',0
kw_while db 'while',0
kw_for db 'for',0
kw_break db 'break',0
kw_continue db 'continue',0
kw_true db 'true',0
kw_false db 'false',0
kw_null db 'null',0
kw_load db 'load',0
kw_store db 'store',0
kw_compare db 'compare',0
kw_jump db 'jump',0
kw_call db 'call',0
kw_write db 'write.value.to.output',0
kw_exit db 'exit.program',0

section .bss

align 8
token_types resq 4096
token_values resq 4096
token_count resq 1
token_data resb 1048576
token_data_used resq 1
current_value resq 1

section .text

global lexer_tokenize
global source
global token_types
global token_values
global token_count

lexer_tokenize:

    push rbx
    push r12
    push r13

    xor r12,r12
    mov [token_count],r12
    mov [token_data_used],r12
    mov rsi,source

.next:

    call skip_space

    mov al,[rsi]
    test al,al
    jz .done

    cmp al,'{'
    je .left_brace

    cmp al,'}'
    je .right_brace

    cmp al,'('
    je .left_paren

    cmp al,')'
    je .right_paren

    cmp al,'<'
    je .left_angle

    cmp al,'>'
    je .right_angle

    cmp al,'='
    je .equal

    cmp al,':'
    je .colon

    cmp al,','
    je .comma

    cmp al,'+'
    je .plus

    cmp al,'-'
    je .minus

    cmp al,'*'
    je .multiply

    cmp al,'/'
    je .divide

    cmp al,'!'
    je .not

    cmp al,'"'
    je .string

    cmp al,'0'
    jb .identifier

    cmp al,'9'
    jbe .number

.identifier:

    call read_identifier
    call classify_identifier
    jmp .next

.number:

    call read_number

    mov rdi,3
    call emit_token

    jmp .next

.string:

    call read_string

    mov rdi,4
    call emit_token

    jmp .next

.left_brace:

    inc rsi
    mov rdi,5
    call emit_empty
    jmp .next

.right_brace:

    inc rsi
    mov rdi,6
    call emit_empty
    jmp .next

.left_paren:

    inc rsi
    mov rdi,7
    call emit_empty
    jmp .next

.right_paren:

    inc rsi
    mov rdi,8
    call emit_empty
    jmp .next

.left_angle:

    inc rsi
    mov rdi,9
    call emit_empty
    jmp .next

.right_angle:

    inc rsi
    mov rdi,10
    call emit_empty
    jmp .next

.equal:

    inc rsi
    mov rdi,11
    call emit_empty
    jmp .next

.colon:

    inc rsi
    mov rdi,12
    call emit_empty
    jmp .next

.comma:

    inc rsi
    mov rdi,13
    call emit_empty
    jmp .next

.plus:

    inc rsi
    mov rdi,14
    call emit_empty
    jmp .next

.minus:

    inc rsi
    mov rdi,15
    call emit_empty
    jmp .next

.multiply:

    inc rsi
    mov rdi,16
    call emit_empty
    jmp .next

.divide:

    inc rsi
    mov rdi,17
    call emit_empty
    jmp .next

.not:

    inc rsi

    cmp byte [rsi],'='
    je .not_equal

    mov rdi,18
    call emit_empty

    jmp .next

.not_equal:

    inc rsi
    mov rdi,19
    call emit_empty

    jmp .next

.done:

    mov rdi,0
    call emit_empty

    xor rax,rax

    pop r13
    pop r12
    pop rbx

    ret

skip_space:

.loop:

    mov al,[rsi]

    cmp al,' '
    je .skip

    cmp al,10
    je .skip

    cmp al,9
    je .skip

    cmp al,13
    je .skip

    ret

.skip:

    inc rsi
    jmp .loop

read_identifier:

    mov rax,[token_data_used]

    mov [current_value],rax

    mov rdi,token_data
    add rdi,rax

    xor rcx,rcx

.loop:

    mov al,[rsi]

    test al,al
    jz .done

    cmp al,' '
    je .done

    cmp al,10
    je .done

    cmp al,9
    je .done

    cmp al,13
    je .done

    cmp al,'{'
    je .done

    cmp al,'}'
    je .done

    cmp al,'('
    je .done

    cmp al,')'
    je .done

    cmp al,'<'
    je .done

    cmp al,'>'
    je .done

    cmp al,'='
    je .done

    cmp al,':'
    je .done

    cmp al,','
    je .done

    cmp al,'+'
    je .done

    cmp al,'-'
    je .done

    cmp al,'*'
    je .done

    cmp al,'/'
    je .done

    cmp al,'!'
    je .done

    mov [rdi+rcx],al

    inc rcx
    inc rsi

    cmp rcx,1023
    jb .loop

.done:

    mov byte [rdi+rcx],0

    mov rax,[token_data_used]
    add rax,rcx
    inc rax

    mov [token_data_used],rax

    ret

read_number:

    mov rax,[token_data_used]

    mov [current_value],rax

    mov rdi,token_data
    add rdi,rax

    xor rcx,rcx

.loop:

    mov al,[rsi]

    cmp al,'0'
    jb .done

    cmp al,'9'
    ja .done

    mov [rdi+rcx],al

    inc rcx
    inc rsi

    cmp rcx,1023
    jb .loop

.done:

    mov byte [rdi+rcx],0

    mov rax,[token_data_used]
    add rax,rcx
    inc rax

    mov [token_data_used],rax

    ret

read_string:

    inc rsi

    mov rax,[token_data_used]

    mov [current_value],rax

    mov rdi,token_data
    add rdi,rax

    xor rcx,rcx

.loop:

    mov al,[rsi]

    test al,al
    jz .done

    cmp al,'"'
    je .closed

    cmp al,'\'
    jne .copy

    inc rsi

    mov al,[rsi]

    test al,al
    jz .done

.copy:

    mov [rdi+rcx],al

    inc rcx
    inc rsi

    cmp rcx,1023
    jb .loop

.closed:

    inc rsi

.done:

    mov byte [rdi+rcx],0

    mov rax,[token_data_used]
    add rax,rcx
    inc rax

    mov [token_data_used],rax

    ret

classify_identifier:

    push rsi

    mov rdi,kw_section
    call equal_token
    jc .keyword

    mov rdi,kw_main
    call equal_token
    jc .keyword

    mov rdi,kw_define
    call equal_token
    jc .keyword

    mov rdi,kw_function
    call equal_token
    jc .keyword

    mov rdi,kw_structure
    call equal_token
    jc .keyword

    mov rdi,kw_immutable
    call equal_token
    jc .keyword

    mov rdi,kw_mutable
    call equal_token
    jc .keyword

    mov rdi,kw_property
    call equal_token
    jc .keyword

    mov rdi,kw_variable
    call equal_token
    jc .keyword

    mov rdi,kw_return
    call equal_token
    jc .keyword

    mov rdi,kw_if
    call equal_token
    jc .keyword

    mov rdi,kw_else
    call equal_token
    jc .keyword

    mov rdi,kw_while
    call equal_token
    jc .keyword

    mov rdi,kw_for
    call equal_token
    jc .keyword

    mov rdi,kw_break
    call equal_token
    jc .keyword

    mov rdi,kw_continue
    call equal_token
    jc .keyword

    mov rdi,kw_true
    call equal_token
    jc .keyword

    mov rdi,kw_false
    call equal_token
    jc .keyword

    mov rdi,kw_null
    call equal_token
    jc .keyword

    mov rdi,kw_load
    call equal_token
    jc .keyword

    mov rdi,kw_store
    call equal_token
    jc .keyword

    mov rdi,kw_compare
    call equal_token
    jc .keyword

    mov rdi,kw_jump
    call equal_token
    jc .keyword

    mov rdi,kw_call
    call equal_token
    jc .keyword

    mov rdi,kw_write
    call equal_token
    jc .keyword

    mov rdi,kw_exit
    call equal_token
    jc .keyword

    pop rsi

    mov rdi,2
    call emit_token

    ret

.keyword:

    pop rsi

    mov rdi,1
    call emit_token

    ret

equal_token:

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

emit_token:

    push rax
    push rbx
    push rcx

    mov rax,[token_count]
    mov rbx,rax

    mov [token_types+rbx*8],rdi

    mov rax,[current_value]

    mov rcx,token_data
    add rax,rcx

    mov [token_values+rbx*8],rax

    mov rax,[token_count]
    inc rax

    mov [token_count],rax

    pop rcx
    pop rbx
    pop rax

    ret

emit_empty:

    push rax
    push rbx

    mov rax,[token_count]
    mov rbx,rax

    mov [token_types+rbx*8],rdi
    mov qword [token_values+rbx*8],0

    inc rax

    mov [token_count],rax

    pop rbx
    pop rax

    ret