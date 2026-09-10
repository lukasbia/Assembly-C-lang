# Assembly-C language notes

Assembly-C uses Swift-inspired declaration names and operators while retaining
an assembly-oriented mental model.

Declarations:

    var name: i64 = 10
    let name: i64 = 10

`var` creates mutable storage. `let` creates immutable storage.

The keyword table is fixed. The lexer never treats an unknown word as a
keyword.

The compiler is designed around an explicit target backend. x86-64 is the
first backend; additional ARM64, RISC-V and other targets belong under
`targets/` and implement the same emitter contract.
