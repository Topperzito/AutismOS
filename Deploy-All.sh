#!/usr/bin/env bash

set -euo pipefail

# Get absolute path of script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Move to repo root (assumes script lives in repo root)
cd "$SCRIPT_DIR"

echo "Scanning from: $SCRIPT_DIR"

# Find all regular files excluding .git
find . -type f ! -path "*/.git/*" | while read -r file; do

    # Get last line safely
    last_line="$(tail -n 1 "$file" || true)"

    # Check marker format
    if [[ "$last_line" =~ ^#\<--\[(.*)\]--\># ]]; then

        target_dir="${BASH_REMATCH[1]}"

        # Expand ~
        target_dir="${target_dir/#\~/$HOME}"

        echo "Deploying $file -> $target_dir"

        mkdir -p "$target_dir"

        tmpfile="$(mktemp)"

        # Remove last line
        sed '$d' "$file" > "$tmpfile"

        cp "$tmpfile" "$target_dir/$(basename "$file")"

        rm "$tmpfile"
    fi
done

echo "Done."
