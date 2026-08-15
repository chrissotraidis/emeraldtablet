#!/usr/bin/env bash
# Confirm required original-data markers exist. Print no hashes or file lists.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${1:-$ROOT_DIR/ref/Pharaoh + Cleopatra}"

fail() {
    echo "Ref marker check failed: $*" >&2
    exit 1
}

[[ -d "$DATA_DIR" ]] || fail "data directory is missing"

campaign=""
for name in campaign.txt Campaign.txt CAMPAIGN.TXT; do
    if [[ -f "$DATA_DIR/$name" ]]; then
        campaign="$name"
        break
    fi
done
[[ -n "$campaign" ]] || fail "campaign.txt is missing"

data_folder=""
for name in Data DATA data; do
    if [[ -d "$DATA_DIR/$name" ]]; then
        data_folder="$name"
        break
    fi
done
[[ -n "$data_folder" ]] || fail "Data/ is missing"

cleopatra=""
for name in Expansion.sg3 Expansion.SG3 SprMain2.sg3 SprMain2.SG3; do
    if [[ -f "$DATA_DIR/$data_folder/$name" ]]; then
        cleopatra="$name"
        break
    fi
done

echo "campaign marker: present"
echo "data folder: present"
if [[ -n "$cleopatra" ]]; then
    echo "cleopatra pack marker: present"
else
    echo "cleopatra pack marker: missing"
    exit 1
fi
