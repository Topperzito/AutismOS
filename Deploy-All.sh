#!/usr/bin/env bash
set -euo pipefail

########################################
# Initialization
########################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR"

PLUGIN_DIR="$SCRIPT_DIR/Deployment/Plugins"

echo "Scanning from: $SCRIPT_DIR"

DEPLOY_ROOTS=(
  "$SCRIPT_DIR/Configs"
  "$SCRIPT_DIR/Apps-Workarounds"
  "$SCRIPT_DIR/Files"
  "$SCRIPT_DIR/Tests"
)


########################################
# Recursive Processor
########################################

process_directory() {
    local dir="$1"

    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(
        find "$dir" -type f -print0
    )
}


########################################
# File Processor
########################################

process_file() {
    local file="$1"

    # Extract ALL markers anywhere in file
    local markers
    markers="$(grep -oE '#<--\[.*\]-->#' "$file" || true)"

    [[ -z "$markers" ]] && return 0

    while IFS= read -r marker; do

        # Strip wrapper
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

        local BASENAME
        BASENAME="$(basename -- "$file")"

        local SOURCE="$file"
        local TARGET="$target_dir"
        local CHMOD="$chmod_value"
        local TMPFILE

        ########################################
        # Prepare file copy
        ########################################

        if [[ "$type_value" != "deployable-archive" && \
              "$type_value" != "archive" ]]; then

            TMPFILE="$(mktemp)"

            # Remove ALL marker lines safely
            sed '/#<--\[.*\]-->#/d' -- "$SOURCE" > "$TMPFILE"

        else
            TMPFILE="$SOURCE"
        fi

        ########################################
        # Export environment for plugins
        ########################################

        export SOURCE TARGET CHMOD BASENAME TMPFILE SCRIPT_DIR
        export -f process_directory

        local plugin_file="$PLUGIN_DIR/$type_value.json"

        ########################################
        # Plugin execution
        ########################################

        if [[ -f "$plugin_file" ]]; then

            local plugin_script
            plugin_script="$(jq -r '.script // empty' "$plugin_file")"

            if [[ -n "$plugin_script" && -f "$PLUGIN_DIR/$plugin_script" ]]; then

                env SOURCE="$SOURCE" \
                    TARGET="$TARGET" \
                    CHMOD="$CHMOD" \
                    BASENAME="$BASENAME" \
                    TMPFILE="$TMPFILE" \
                    SCRIPT_DIR="$SCRIPT_DIR" \
                    bash "$PLUGIN_DIR/$plugin_script"

            else
                local command_template
                command_template="$(jq -r '.command // empty' "$plugin_file")"

                if [[ -z "$command_template" ]]; then
                    echo "Invalid plugin definition: $plugin_file"
                    exit 1
                fi

                bash -c "$command_template"
            fi

        else
            ########################################
            # Default fallback installer
            ########################################

            echo "  → plugin not found, using default installer"

            install -m "$CHMOD" \
                -- "$TMPFILE" \
                "$TARGET/$BASENAME"
        fi

        ########################################
        # Cleanup
        ########################################

        if [[ "$TMPFILE" != "$SOURCE" ]]; then
            rm -f -- "$TMPFILE"
        fi

    done <<< "$markers"
}

########################################
# Initial Scan
########################################
for root in "${DEPLOY_ROOTS[@]}"; do
    [[ -d "$root" ]] || continue

    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(
        find "$root" -type f -print0
    )
done

echo "Deployment complete."
