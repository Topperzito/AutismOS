#!/usr/bin/env bash
set -euo pipefail

: "${SOURCE:?SOURCE not set}"
: "${TARGET:?TARGET not set}"
: "${SCRIPT_DIR:?SCRIPT_DIR not set}"

echo "  → validating archive"

if ! file --mime-type "$SOURCE" | grep -Eq 'application/(x-tar|gzip|x-gzip|x-xz|x-bzip2)'; then
    echo "  → Not a valid tar archive, skipping."
    exit 0
fi

echo "  → extracting archive"

if ! tar -xf "$SOURCE" -C "$TARGET"; then
    echo "  → extraction failed."
    exit 1
fi

manifest="$TARGET/___archived-meta___"

if [[ -f "$manifest" ]]; then
    echo "  → manifest detected"

    jq -c '.deploy[]' "$manifest" | while read -r entry; do
        SRC=$(echo "$entry" | jq -r '.source')
        DEST=$(echo "$entry" | jq -r '.target')
        TYPE=$(echo "$entry" | jq -r '.type // "file"')
        MODE=$(echo "$entry" | jq -r '.chmod // "644"')

        DEST_EXPANDED=${DEST/#~/$HOME}
        mkdir -p "$DEST_EXPANDED"

        case "$TYPE" in
            file)
                install -m "$MODE" \
                    "$TARGET/$SRC" \
                    "$DEST_EXPANDED/$(basename "$SRC")"
                ;;
            symlink)
                ln -sfn \
                    "$TARGET/$SRC" \
                    "$DEST_EXPANDED/$(basename "$SRC")"
                ;;
            directory)
                cp -r \
                    "$TARGET/$SRC" \
                    "$DEST_EXPANDED/"
                ;;
            *)
                echo "Unknown manifest type: $TYPE"
                ;;
        esac
    done
else
    echo "  → no manifest found, scanning recursively"
    process_directory "$TARGET"
fi
