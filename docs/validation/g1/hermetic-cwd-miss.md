# G1 hermetic cwd miss

Date: 2026-08-13
Host: Chris-Macbook-Air-M1.local, macOS 26.5.2

## Command

Ran the patched app from the wrapper root:

```sh
./build/macos/akhenaten.app/Contents/MacOS/akhenaten \
  --integraltests --no-logo --no-resource --window --size 800x600
```

## Result

- Process exit 0
- Log: `Attempting to load game from /Users/chrissotraidis/GitHub/emeraldtablet`
- `[integraltests] 0 test file(s)`
- `error: [integraltests] no .js test files found under tests/`
- then `[integraltests] all checks passed`

The driver lists `tests/*.js` and `../tests/*.js` from the process cwd. The
wrapper `tests/` tree has no JS files, so discovery is empty. Upstream treats
that empty list as success unless `--integraltest-only` was requested.

The earlier unpatched `01_main_menu` smoke started from
`engines/akhenaten` and listed 194 files.

## What this proves

- Wrapper-root invocation is not a hermetic baseline.
- Empty-suite exit 0 is a harness miss, not a green suite.

## Next

`scripts/run-macos-hermetic.sh` now cds to `engines/akhenaten` and fails if
the driver reports 0 test files.

## Fact vs inference

Fact.
