#!/usr/bin/env bash
set -euo pipefail

: "${SOURCE:?SOURCE not set}"
: "${TARGET:?TARGET not set}"
: "${SCRIPT_DIR:?SCRIPT_DIR not set}"

echo "  → extracting archive"

# Allow trailing metadata
tar -xzf "$SOURCE" -C "$TARGET" || true

if [[ -f "$TARGET/___archived-meta___" ]]; then
    echo "  → manifest detected"

    jq -c '.deploy[]' "$TARGET/___archived-meta___" | while read -r entry; do
        SRC=$(echo "$entry" | jq -r '.source')
        DEST=$(echo "$entry" | jq -r '.target')
        TYPE=$(echo "$entry" | jq -r '.type // "file"')
        MODE=$(echo "$entry" | jq -r '.chmod // "644"')

        DEST_EXPANDED=${DEST/#~/$HOME}
        mkdir -p "$DEST_EXPANDED"

        case "$TYPE" in
            file)
                install -m "$MODE" "$TARGET/$SRC" "$DEST_EXPANDED/$(basename "$SRC")"
                ;;
            symlink)
                ln -sfn "$TARGET/$SRC" "$DEST_EXPANDED/$(basename "$SRC")"
                ;;
            directory)
                cp -r "$TARGET/$SRC" "$DEST_EXPANDED/"
                ;;
            *)
                echo "Unknown manifest type: $TYPE"
                ;;
        esac
    done
else
    echo "  → no manifest found, scanning recursively"
    "$SCRIPT_DIR/Deploy-All.sh" --scan-dir "$TARGET"
fi
