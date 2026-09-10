#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
mkdir -p "$BUILD"

NASM="${NASM:-nasm}"
LD="${LD:-ld}"

"$NASM" -f elf64 "$ROOT/src/asc.asm" -o "$BUILD/asc.o"
"$NASM" -f elf64 "$ROOT/runtime/runtime.asm" -o "$BUILD/runtime.o"

"$LD" "$BUILD/asc.o" "$BUILD/runtime.o" -o "$BUILD/asc"

echo "built: $BUILD/asc"
