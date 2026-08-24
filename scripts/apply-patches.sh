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

# Avoid touching every patched source file on an unchanged repeat build. The
# state lives under ignored build/ and is accepted only while the engine HEAD,
# patch bytes, and complete engine diff are all identical to the last apply.
STATE_FILE="$ROOT_DIR/build/.akhenaten-patch-state"
ENGINE_HEAD="$(git -C "$ENGINE_DIR" rev-parse HEAD)"
PATCH_FINGERPRINT="$({
    for patch in "${patches[@]}"; do
        shasum -a 256 "$patch"
    done
} | shasum -a 256 | awk '{print $1}')"

engine_diff_fingerprint() {
    {
        git -C "$ENGINE_DIR" diff --binary --no-ext-diff HEAD --
        while IFS= read -r -d '' untracked; do
            printf '\0%s\0' "$untracked"
            shasum -a 256 "$ENGINE_DIR/$untracked"
        done < <(git -C "$ENGINE_DIR" ls-files --others --exclude-standard -z)
    } | shasum -a 256 | awk '{print $1}'
}

if [[ -f "$STATE_FILE" ]]; then
    previous_head="$(sed -n '1p' "$STATE_FILE")"
    previous_patches="$(sed -n '2p' "$STATE_FILE")"
    previous_diff="$(sed -n '3p' "$STATE_FILE")"
    if [[ "$previous_head" == "$ENGINE_HEAD" \
        && "$previous_patches" == "$PATCH_FINGERPRINT" \
        && "$previous_diff" == "$(engine_diff_fingerprint)" ]]; then
        echo "Akhenaten patch queue already applied; source tree unchanged."
        exit 0
    fi
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

mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n%s\n%s\n' \
    "$ENGINE_HEAD" \
    "$PATCH_FINGERPRINT" \
    "$(engine_diff_fingerprint)" > "$STATE_FILE"
