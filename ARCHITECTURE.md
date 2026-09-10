# Compiler architecture

## Lexer

Consumes bytes and emits stable token IDs. Keywords are matched against the
fixed 127-entry table.

## Parser

Consumes the token stream and builds AST nodes.

## Semantic analyzer

Resolves declarations, scopes, mutability and types.

## Generator

Converts validated AST nodes into target-independent IR.

## Emitter

Converts IR into target assembly.

## Driver

`asc` owns file handling, diagnostics, target selection and the stage pipeline.
