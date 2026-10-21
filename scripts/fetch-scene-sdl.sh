#!/usr/bin/env bash
# Fetch SDL 2.32.10 plus the Pad ports UIKit scene startup commit and print its
# path. Apps built with the iOS 27 SDK must start through UIKit scenes or iOS 27
# closes them at launch; Akhenaten otherwise fetches plain release-2.32.10.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDL_DIR="$ROOT_DIR/build/deps/sdl2-scenes"
SDL_PIN="c6756fcd3de8090a8f72ac1a0b6fb6e50f0021d1"

if [[ "$(git -C "$SDL_DIR" rev-parse HEAD 2>/dev/null || true)" != "$SDL_PIN" ]]; then
    rm -rf "$SDL_DIR"
    git init -q "$SDL_DIR"
    git -C "$SDL_DIR" fetch -q --depth 1 https://github.com/chrissotraidis/SDL.git "$SDL_PIN"
    git -C "$SDL_DIR" checkout -q --detach FETCH_HEAD
fi
echo "$SDL_DIR"
