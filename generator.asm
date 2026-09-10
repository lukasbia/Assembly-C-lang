%include "../include/ast.inc"
%include "../include/ir.inc"

global asc_generator_init
global asc_generate

section .bss
ir_buffer: resb 65536
ir_count: resq 1

section .text
asc_generator_init:
    xor eax, eax
    mov [ir_count], rax
    ret

asc_generate:
    test rdi, rdi
    jz .error
    lea rax, [ir_buffer]
    mov qword [rax], IR_NOP
    mov qword [ir_count], 1
    ret
.error:
    xor eax, eax
    ret
