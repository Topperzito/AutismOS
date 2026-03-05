#!/usr/bin/env bash
# Interactive NixOS rebuild + evaluation warning refactor assistant

set -euo pipefail

CONFIG_DIR="/etc/nixos"
TMP_LOG="$(mktemp)"

apply_replace() {
    local file="$1"
    local line="$2"
    local old="$3"
    local new="$4"

    if [[ -w "$file" ]]; then
        sed -i "${line}s|$old|$new|g" "$file"
    else
        sudo sed -i "${line}s|$old|$new|g" "$file"
    fi
}

apply_replace_all() {
    local file="$1"
    local old="$2"
    local new="$3"

    if [[ -w "$file" ]]; then
        sed -i "s|$old|$new|g" "$file"
    else
        sudo sed -i "s|$old|$new|g" "$file"
    fi
}

echo "⚙ Running nixos-rebuild switch --upgrade..."
echo "--------------------------------------------------"

if ! sudo nixos-rebuild switch --upgrade 2>&1 | tee "$TMP_LOG"; then
    echo "⚠ Rebuild exited with error. Continuing analysis..."
fi

echo
echo "🔍 Parsing evaluation warnings..."
echo "--------------------------------------------------"

mapfile -t WARNINGS < <(grep "evaluation warning:" "$TMP_LOG" || true)

if [[ ${#WARNINGS[@]} -eq 0 ]]; then
    echo "✅ No evaluation warnings detected."
    rm -f "$TMP_LOG"
    exit 0
fi

printf '%s\n\n' "${WARNINGS[@]}"

for line in "${WARNINGS[@]}"; do

    OLD=$(echo "$line" | sed -n "s/.*‘\([^’]*\)’ was moved.*/\1/p")
    NEW=$(echo "$line" | sed -n "s/.*Please use ‘\([^’]*\)’ directly.*/\1/p")

    if [[ -z "$OLD" || -z "$NEW" ]]; then
        continue
    fi

    echo "⚠ Rename detected:"
    echo "   OLD: $OLD"
    echo "   NEW: $NEW"
    echo

    mapfile -t MATCHES < <(grep -R --line-number --color=never "$OLD" "$CONFIG_DIR" || true)

    if [[ ${#MATCHES[@]} -eq 0 ]]; then
        echo "No occurrences found."
        echo
        continue
    fi

    printf 'Occurrences:\n%s\n\n' "${MATCHES[@]}"

    read -rp "[Y/n/c] Replace ALL / Skip / Controlled? " CHOICE

    case "$CHOICE" in

        Y|y)
            mapfile -t FILES < <(grep -Rl "$OLD" "$CONFIG_DIR" || true)
            for file in "${FILES[@]}"; do
                apply_replace_all "$file" "$OLD" "$NEW"
                echo "✔ Updated $file"
            done
            echo
            ;;

        n|N)
            echo "Skipped."
            echo
            ;;

        c|C)
            for entry in "${MATCHES[@]}"; do
                FILE=$(echo "$entry" | cut -d: -f1)
                LINE=$(echo "$entry" | cut -d: -f2)
                CONTENT=$(echo "$entry" | cut -d: -f3-)

                echo
                echo "File : $FILE"
                echo "Line : $LINE"
                echo "Code : $CONTENT"

                read -rp "Replace this occurrence? [y/N] " CONFIRM

                if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                    apply_replace "$FILE" "$LINE" "$OLD" "$NEW"
                    echo "✔ Replaced."
                else
                    echo "Skipped."
                fi
            done
            echo
            ;;

        *)
            echo "Invalid choice. Skipping."
            echo
            ;;
    esac

done

rm -f "$TMP_LOG"

echo "🏁 Finished processing evaluation warnings."
exit 0
