#!/usr/bin/env bash
# Link local-only reference checkouts. Never copies original game files.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REF_DIR="$ROOT_DIR/ref"
ENGINE_DIR="$ROOT_DIR/engines/akhenaten"
CAESARPAD_DIR="${CAESARPAD_DIR:-$REF_DIR/caesarpad}"

mkdir -p "$REF_DIR"

if [[ -e "$ENGINE_DIR/CMakeLists.txt" && ! -e "$REF_DIR/Akhenaten" ]]; then
    ln -s "$ENGINE_DIR" "$REF_DIR/Akhenaten"
    echo "Linked ref/Akhenaten -> engines/akhenaten"
fi

if [[ -d "$CAESARPAD_DIR/.git" ]]; then
    echo "Found local CaesarPad checkout under ref/ (contents stay private)."
elif [[ -d /Users/chrissotraidis/GitHub/caesarpad/.git && ! -e "$REF_DIR/caesarpad" ]]; then
    ln -s /Users/chrissotraidis/GitHub/caesarpad "$REF_DIR/caesarpad"
    echo "Linked ref/caesarpad -> /Users/chrissotraidis/GitHub/caesarpad"
fi

if [[ -d "$REF_DIR/Pharaoh + Cleopatra" ]]; then
    echo "Found local Pharaoh + Cleopatra folder (contents stay private)."
else
    echo "No local Pharaoh + Cleopatra folder yet. Place a legally obtained install at:"
    echo "  $REF_DIR/Pharaoh + Cleopatra"
fi
