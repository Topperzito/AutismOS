#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage:"
    echo "  pack-deployable.sh <name> <inputs...> -l LOCATION [-p PERMS]"
    exit 1
}

[[ $# -lt 3 ]] && usage

NAME="$1"
shift

INPUTS=()
LOCATION=""
PERMS="644"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l)
            LOCATION="$2"
            shift 2
            ;;
        -p)
            PERMS="$2"
            shift 2
            ;;
        -*)
            echo "Unknown flag: $1"
            usage
            ;;
        *)
            INPUTS+=("$1")
            shift
            ;;
    esac
done

[[ -z "$LOCATION" ]] && {
    echo "Location (-l) required."
    exit 1
}

ARCHIVE="${NAME}.tar.gz"

for item in "${INPUTS[@]}"; do
    [[ -e "$item" ]] || { echo "Input not found: $item"; exit 1; }
done

echo "Creating archive: $ARCHIVE"
tar -czf "$ARCHIVE" "${INPUTS[@]}"

# Remove old marker if exists
if tail -n 1 "$ARCHIVE" | grep -q '^#<--\[.*\]-->#$'; then
    filesize=$(stat -c%s "$ARCHIVE")
    marker=$(tail -n 1 "$ARCHIVE")
    marker_len=$(printf "%s" "$marker" | wc -c)
    head -c $((filesize - marker_len - 1)) "$ARCHIVE" > "${ARCHIVE}.tmp"
    mv "${ARCHIVE}.tmp" "$ARCHIVE"
fi

printf "\n#<--[%s|type=deployable-archive|chmod=%s]-->#" \
    "$LOCATION" "$PERMS" >> "$ARCHIVE"

echo "Deployable archive created:"
echo "  $ARCHIVE"
