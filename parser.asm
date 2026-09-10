%include "../include/tokens.inc"
%include "../include/ast.inc"

global asc_parser_init
global asc_parse_program

extern asc_lexer_next
extern asc_lexer_token_kind
extern asc_lexer_token_value

section .bss
parser_token: resq 1
parser_value: resq 1
parser_nodes: resb 8192 * ASTNode_size
parser_count: resq 1

section .text
asc_parser_init:
    call asc_lexer_next
    mov [parser_token], rax
    call asc_lexer_token_value
    mov [parser_value], rax
    xor eax, eax
    mov [parser_count], rax
    ret

asc_parse_program:
    mov rax, parser_nodes
    mov qword [rax+ASTNode.kind], AST_PROGRAM
    mov qword [rax+ASTNode.left], 0
    mov qword [rax+ASTNode.right], 0
    mov qword [parser_count], 1
    ret
