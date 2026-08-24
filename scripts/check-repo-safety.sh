#!/usr/bin/env bash
# Block original game data, generated packages, and signing material.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
    echo "Repository safety check failed: $*" >&2
    exit 1
}

current_files="$(git ls-files --cached --others --exclude-standard | sort -u)"

tracked_ref_files="$(printf '%s\n' "$current_files" |
    grep '^ref/' | grep -v '^ref/README\.md$' || true)"
if [[ -n "$tracked_ref_files" ]]; then
    echo "$tracked_ref_files" >&2
    fail "ref/ is local-only and may contain only ref/README.md"
fi

forbidden_extensions='\.(sg2|sg3|555|sav|svx|bik|smk|exe|ipa|xcarchive|mobileprovision|provisionprofile|p12|p8|pem|key)(/|$)'
forbidden_names='(^|/)(campaign\.txt|Campaign\.txt|CAMPAIGN\.TXT|Pharaoh\.exe|Pharaoh_Text\.(eng|txt)|Pharaoh_Fonts\.(sg3|SG3))(/|$)'
forbidden_current="$(printf '%s\n' "$current_files" |
    grep -Ei "$forbidden_extensions|$forbidden_names|(^|/)[^/]+\.app/" || true)"
if [[ -n "$forbidden_current" ]]; then
    printf '%s\n' "$forbidden_current" >&2
    fail "original game data, generated products, packages, or signing material is tracked"
fi

# Audit publishable history only. Local Codex snapshot refs can contain ignored files.
history_paths="$(git rev-list --objects --branches --remotes --tags 2>/dev/null |
    awk 'NF > 1 { sub(/^[^ ]+ /, ""); print }' || true)"
forbidden_history="$(printf '%s\n' "$history_paths" |
    grep -Ei "$forbidden_extensions|$forbidden_names|(^|/)[^/]+\.app/|^ref/" |
    grep -v '^ref/README\.md$' || true)"
if [[ -n "$forbidden_history" ]]; then
    printf '%s\n' "$forbidden_history" >&2
    fail "prohibited material exists in Git history"
fi

while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    size="$(wc -c < "$file")"
    if [[ "$size" -gt 5242880 ]]; then
        echo "$file ($size bytes)" >&2
        fail "tracked file exceeds the 5 MiB review limit"
    fi
done < <(printf '%s\n' "$current_files")

credential_pattern='(-----BEGIN [A-Z ]*PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})'
credential_hits=""
while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    matches="$(grep -nEI "$credential_pattern" "$file" 2>/dev/null || true)"
    if [[ -n "$matches" ]]; then
        credential_hits="${credential_hits}${file}:${matches}"$'\n'
    fi
done < <(printf '%s\n' "$current_files")
if [[ -n "$credential_hits" ]]; then
    printf '%s' "$credential_hits" >&2
    fail "a likely credential or private key exists in the current tree"
fi

if compgen -G 'scripts/*.sh' >/dev/null; then
    bash -n scripts/*.sh
    for script in scripts/*.sh; do
        [[ -x "$script" ]] || fail "$script is not executable"
    done
fi

if compgen -G 'patches/akhenaten/*.patch' >/dev/null; then
    for patch in patches/akhenaten/*.patch; do
        git apply --numstat "$patch" >/dev/null ||
            fail "$patch is not a syntactically valid patch"
    done
fi

if [[ -d engines/akhenaten/.git || -f engines/akhenaten/.git ]]; then
    expected_pin="38cb947ead3895408ea32f74fda6e37921a42bd3"
    actual_pin="$(git -C engines/akhenaten rev-parse HEAD)"
    if [[ "$actual_pin" != "$expected_pin" ]]; then
        fail "engines/akhenaten is $actual_pin, expected $expected_pin"
    fi

    engine_status="$(git -C engines/akhenaten status --porcelain)"
    # New files created by the patch queue are legitimately untracked in the
    # submodule (git apply adds them outside the tracked tree). Allow exactly
    # those; any other untracked file means the checkout drifted from the pin.
    shopt -s nullglob
    engine_patches=(patches/akhenaten/*.patch)
    shopt -u nullglob
    patch_new_files=""
    for patch in "${engine_patches[@]}"; do
        patch_new_files+="$(git apply --numstat "$patch" 2>/dev/null |
            awk 'NF >= 3 {print $3}' |
            while IFS= read -r f; do
                git -C engines/akhenaten ls-files --error-unmatch "$f" >/dev/null 2>&1 || printf '%s\n' "$f"
            done)"$'\n'
    done
    allowed_untracked="$(printf '%s' "$patch_new_files" | sort -u | sed '/^$/d')"
    engine_untracked="$(git -C engines/akhenaten status --porcelain --untracked-files=all |
        awk '$1 == "??" {print $2}' | sort -u)"
    allowed_untracked="$(printf '%s\n%s\n' "$allowed_untracked" \
        'res/ios/Assets.xcassets/AppIcon.appiconset/AppIcon.png' | sort -u | sed '/^$/d')"
    extra_untracked="$(comm -23 <(printf '%s\n' "$engine_untracked") <(printf '%s\n' "$allowed_untracked") || true)"
    if [[ -n "$extra_untracked" ]]; then
        printf '%s\n' "$extra_untracked" >&2
        fail "engines/akhenaten has untracked files outside the patch queue; reconstruct from the pin plus patches/akhenaten"
    fi

    if [[ ${#engine_patches[@]} -eq 0 ]]; then
        if [[ -n "$engine_status" ]]; then
            fail "engines/akhenaten is dirty; reconstruct from the pin plus patches/akhenaten"
        fi
    else
        patched_files="$(git apply --numstat "${engine_patches[@]}" |
            awk 'NF >= 3 {print $3}' | sort -u)"
        dirty_files="$(git -C engines/akhenaten status --porcelain --untracked-files=all |
            awk '{print $NF}' | grep -v '^res/ios/Assets\.xcassets/AppIcon\.appiconset/AppIcon\.png$' | sort -u)"
        extra_dirty="$(comm -23 <(printf '%s\n' "$dirty_files") <(printf '%s\n' "$patched_files") || true)"
        if [[ -n "$extra_dirty" ]]; then
            printf '%s\n' "$extra_dirty" >&2
            fail "engines/akhenaten has edits outside the patch queue"
        fi
        # Patches may touch overlapping regions of the same file, so they must
        # reverse sequentially (last applied first), exactly like apply-patches.sh.
        reversed=0
        for ((index=${#engine_patches[@]} - 1; index >= 0; index--)); do
            patch_path="$ROOT/${engine_patches[$index]}"
            if git -C engines/akhenaten apply --reverse --check "$patch_path" 2>/dev/null; then
                git -C engines/akhenaten apply --reverse "$patch_path"
                reversed=$((reversed + 1))
            else
                fail "${engine_patches[$index]} does not reverse-apply cleanly; reconstruct from the pin plus patches/akhenaten"
            fi
        done
        if [[ "$reversed" -ne "${#engine_patches[@]}" ]]; then
            fail "patch queue did not reverse fully; reconstruct from the pin plus patches/akhenaten"
        fi
        # Restore the working tree so a safety scan never leaves the engine unpatched.
        for patch in "${engine_patches[@]}"; do
            git -C engines/akhenaten apply "$ROOT/$patch" ||
                fail "patch queue did not re-apply after verification; reconstruct from the pin plus patches/akhenaten"
        done
    fi
fi

echo "Repository safety checks passed."
