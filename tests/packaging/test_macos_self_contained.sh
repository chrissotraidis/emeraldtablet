#!/usr/bin/env bash
# Regression for G1 packaging: the Mac app must not leak Homebrew or miss
# the requested deployment target.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_PATH="${1:-${ROOT_DIR}/build/macos/akhenaten.app}"

"$ROOT_DIR/scripts/audit-macos-app.sh" "$APP_PATH"
