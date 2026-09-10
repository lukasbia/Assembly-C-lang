%include "../include/ir.inc"

global asc_emit_x86_64
global asc_emit_header

section .data
header_text: db "global _start",10,"section .text",10,"_start:",10,0
exit_text: db "    mov rax, 60",10,"    xor rdi, rdi",10,"    syscall",10,0

section .text
asc_emit_header:
    mov rax, header_text
    ret

asc_emit_x86_64:
    test rdi, rdi
    jz .error
    mov rax, exit_text
    ret
.error:
    xor eax, eax
    ret
