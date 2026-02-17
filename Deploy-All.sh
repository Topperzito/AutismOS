#!/usr/bin/env bash
set -euo pipefail

# Resolve script directory (repo root assumed)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR"

echo "Scanning from: $SCRIPT_DIR"

# Process files safely (handles spaces, newlines, weird names)
while IFS= read -r -d '' file; do
    last_line="$(tail -n 1 -- "$file" 2>/dev/null || true)"

    # Match marker format: #<--[ ... ]-->
    if [[ "$last_line" =~ ^#\<--\[(.*)\]--\># ]]; then
        raw="${BASH_REMATCH[1]}"

        IFS='|' read -r -a parts <<< "$raw"

        target_dir="${parts[0]/#\~/$HOME}"
        chmod_value="644"
        type_value="file"

        # Parse optional flags
        for part in "${parts[@]:1}"; do
            case "$part" in
                chmod=*) chmod_value="${part#chmod=}" ;;
                type=*)  type_value="${part#type=}"  ;;
            esac
        done

        echo "Deploying $file -> $target_dir"
        echo "  chmod=$chmod_value"
        echo "  type=$type_value"

        mkdir -p -- "$target_dir"

        tmpfile="$(mktemp)"
        sed '$d' -- "$file" > "$tmpfile"

        case "$type_value" in
            archive)
                tar -xf -- "$tmpfile" -C "$target_dir"
                ;;
            symlink)
                ln -sfn -- "$(realpath -- "$file")" \
                    "$target_dir/$(basename -- "$file")"
                ;;
            file)
                install -m "$chmod_value" \
                    -- "$tmpfile" \
                    "$target_dir/$(basename -- "$file")"
                ;;
            *)
                echo "Unknown type: $type_value"
                rm -f -- "$tmpfile"
                exit 1
                ;;
        esac

        rm -f -- "$tmpfile"
    fi

done < <(find . -type f ! -path "*/.git/*" -print0)

echo "Done."
