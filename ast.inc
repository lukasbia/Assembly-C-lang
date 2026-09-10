%ifndef ASC_AST_INC
%define ASC_AST_INC

struc ASTNode
    .kind       resq 1
    .type       resq 1
    .flags      resq 1
    .value      resq 1
    .left       resq 1
    .right      resq 1
    .extra      resq 1
endstruc

%define AST_INT        1
%define AST_IDENT      2
%define AST_VAR        3
%define AST_LET        4
%define AST_ASSIGN     5
%define AST_BINARY     6
%define AST_UNARY      7
%define AST_BLOCK      8
%define AST_WHILE      9
%define AST_IF         10
%define AST_BOOL       11
%define AST_STRING      12
%define AST_RETURN     13
%define AST_CALL       14
%define AST_FUNC       15
%define AST_PROGRAM    16

%endif
