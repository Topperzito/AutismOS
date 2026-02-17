#!/usr/bin/env bash
set -euo pipefail

########################################
# Initialization
########################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR"

PLUGIN_DIR="$SCRIPT_DIR/Deployment/Plugins"

echo "Scanning from: $SCRIPT_DIR"

########################################
# Recursive Processor
########################################

process_directory() {
    local dir="$1"
    while IFS= read -r -d '' f; do
        process_file "$f"
    done < <(find "$dir" -type f -print0)
}

########################################
# File Processor
########################################

process_file() {
    local file="$1"

    # Check for marker safely
    if ! tail -n 1 -- "$file" 2>/dev/null | grep -q '^#<--\[.*\]-->#$'; then
        return 0
    fi

    # Extract marker
    local marker
    marker="$(tail -n 1 -- "$file")"

    local raw
    raw="${marker#\#<--[}"
    raw="${raw%]-->#}"

    IFS='|' read -r -a parts <<< "$raw"

    local target_dir="${parts[0]/#\~/$HOME}"
    local chmod_value="644"
    local type_value="file"

    for part in "${parts[@]:1}"; do
        case "$part" in
            chmod=*) chmod_value="${part#chmod=}" ;;
            type=*)  type_value="${part#type=}" ;;
        esac
    done

    echo "Deploying: $file"
    echo "  → target: $target_dir"
    echo "  → type:   $type_value"
    echo "  → chmod:  $chmod_value"

    mkdir -p -- "$target_dir"

    BASENAME="$(basename -- "$file")"
    SOURCE="$file"
    TARGET="$target_dir"
    CHMOD="$chmod_value"

    # For text types → strip marker
    if [[ "$type_value" != "deployable-archive" && "$type_value" != "archive" ]]; then
        TMPFILE="$(mktemp)"
        sed '$d' -- "$SOURCE" > "$TMPFILE"
    else
        TMPFILE="$SOURCE"
    fi

    export SOURCE TARGET CHMOD BASENAME TMPFILE SCRIPT_DIR
    export -f process_directory

    local plugin_file="$PLUGIN_DIR/$type_value.json"

    if [[ -f "$plugin_file" ]]; then

        # Preferred: script-based plugin
        plugin_script="$(jq -r '.script // empty' "$plugin_file")"

        if [[ -n "$plugin_script" ]]; then
            if [[ -f "$PLUGIN_DIR/$plugin_script" ]]; then
                env SOURCE="$SOURCE" \
                    TARGET="$TARGET" \
                    CHMOD="$CHMOD" \
                    BASENAME="$BASENAME" \
                    TMPFILE="$TMPFILE" \
                    bash "$PLUGIN_DIR/$plugin_script"

            else
                echo "Plugin script not found: $PLUGIN_DIR/$plugin_script"
                exit 1
            fi
        else
            # Fallback: command-based plugin
            command_template="$(jq -r '.command // empty' "$plugin_file")"
            if [[ -z "$command_template" ]]; then
                echo "Invalid plugin definition: $plugin_file"
                exit 1
            fi
            bash -c "$command_template"
        fi

    else
        echo "Plugin not found for type '$type_value', using default installer."
        install -m "$CHMOD" \
            -- "$TMPFILE" \
            "$TARGET/$BASENAME"
    fi

    if [[ "$TMPFILE" != "$SOURCE" ]]; then
        rm -f -- "$TMPFILE"
    fi
}

########################################
# Run
########################################

while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find "$SCRIPT_DIR" -type f ! -path "*/.git/*" -print0)

echo "Deployment complete."
