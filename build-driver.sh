#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$repo_dir/.build"
mkdir -p "$build_dir/src"
cp "$repo_dir/system/opt/turbo-fan/src/facer.c" "$build_dir/src/facer.c"
printf 'obj-m := src/facer.o\n' > "$build_dir/Makefile"
make -C "/usr/lib/modules/$(uname -r)/build" M="$build_dir" LLVM=1 -j2 modules
printf 'Driver built: %s/src/facer.ko\n' "$build_dir"
