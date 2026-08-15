#!/usr/bin/env bash
# Run the full hermetic Akhenaten integral suite on the built macOS app.
# The driver discovers tests/*.js relative to the process working directory,
# so this wrapper always starts from the pinned engine checkout.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/akhenaten"
APP_BIN="${1:-$ROOT_DIR/build/macos/akhenaten.app/Contents/MacOS/akhenaten}"

if [[ ! -x "$APP_BIN" ]]; then
    echo "macOS app executable is missing: $APP_BIN" >&2
    exit 1
fi

if [[ ! -d "$ENGINE_DIR/tests" ]]; then
    echo "Engine tests directory is missing: $ENGINE_DIR/tests" >&2
    exit 1
fi

export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-dummy}"
export SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-dummy}"

cd "$ENGINE_DIR"

tmp_log="$(mktemp -t emeraldtablet-hermetic)"
cleanup() {
    rm -f "$tmp_log"
}
trap cleanup EXIT

set +e
"$APP_BIN" --integraltests --no-logo --no-resource --window --size 800x600 | tee "$tmp_log"
status=${PIPESTATUS[0]}
set -e

if grep -q '\[integraltests\] 0 test file(s)' "$tmp_log"; then
    echo "Hermetic suite found 0 tests (cwd=$PWD). This is a harness miss, not a green baseline." >&2
    exit 1
fi

if ! grep -E '\[integraltests\] [0-9]+ passed' "$tmp_log" >/dev/null; then
    echo "Hermetic suite did not emit a pass/fail summary." >&2
    exit 1
fi

exit "$status"
