%include "../include/ast.inc"

global asc_semantic_init
global asc_semantic_check

asc_semantic_init:
    xor eax, eax
    ret

asc_semantic_check:
    test rdi, rdi
    jz .error
    xor eax, eax
    ret
.error:
    mov eax, 1
    ret
