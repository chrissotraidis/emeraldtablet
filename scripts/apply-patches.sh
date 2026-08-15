#!/usr/bin/env bash
# Apply the ordered Akhenaten patch queue to a clean pinned submodule.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="${ENGINE_DIR:-$ROOT_DIR/engines/akhenaten}"
PATCH_DIR="$ROOT_DIR/patches/akhenaten"

if [[ ! -f "$ENGINE_DIR/CMakeLists.txt" ]]; then
    echo "Akhenaten submodule is missing. Run: git submodule update --init engines/akhenaten" >&2
    exit 1
fi

shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)
shopt -u nullglob

if [[ ${#patches[@]} -eq 0 ]]; then
    echo "No Akhenaten patches to apply."
    exit 0
fi

# Reverse known patches first so overlapping context remains recognizable.
for ((index=${#patches[@]} - 1; index >= 0; index--)); do
    patch="${patches[$index]}"
    if git -C "$ENGINE_DIR" apply --reverse --check "$patch" 2>/dev/null; then
        git -C "$ENGINE_DIR" apply --reverse "$patch"
    fi
done

for patch in "${patches[@]}"; do
    git -C "$ENGINE_DIR" apply --check "$patch"
    git -C "$ENGINE_DIR" apply "$patch"
    echo "Applied: $(basename "$patch")"
done
