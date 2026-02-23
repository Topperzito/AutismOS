#!/usr/bin/env bash
set -euo pipefail

echo "Detecting package manager..."

install_pkgs() {
    local manager="$1"
    shift
    local pkgs=("$@")

    case "$manager" in
        paru)
            paru -S --needed --noconfirm "${pkgs[@]}"
            ;;
        pacman)
            sudo pacman -S --needed --noconfirm "${pkgs[@]}"
            ;;
        apt)
            sudo apt update
            sudo apt install -y "${pkgs[@]}"
            ;;
        dnf)
            sudo dnf install -y "${pkgs[@]}"
            ;;
        zypper)
            sudo zypper install -y "${pkgs[@]}"
            ;;
        xbps-install)
            sudo xbps-install -Sy "${pkgs[@]}"
            ;;
        emerge)
            sudo emerge "${pkgs[@]}"
            ;;
        nix-env)
            nix-env -iA nixpkgs.dia
            ;;
        *)
            echo "Unsupported package manager."
            exit 1
            ;;
    esac
}

# Detection chain (order matters)
if command -v paru >/dev/null; then
    PM="paru"
elif command -v pacman >/dev/null; then
    PM="pacman"
elif command -v apt >/dev/null; then
    PM="apt"
elif command -v dnf >/dev/null; then
    PM="dnf"
elif command -v zypper >/dev/null; then
    PM="zypper"
elif command -v xbps-install >/dev/null; then
    PM="xbps-install"
elif command -v emerge >/dev/null; then
    PM="emerge"
elif command -v nix-env >/dev/null; then
    PM="nix-env"
else
    echo "No supported package manager detected."
    exit 1
fi

echo "Using package manager: $PM"

COMMON_DEPS=(dia)

# GTK2 equivalents differ slightly
case "$PM" in
    paru|pacman)
        EXTRA_DEPS=(gtk2 gtk-engine-murrine)
        ;;
    apt)
        EXTRA_DEPS=(gtk2-engines-murrine)
        ;;
    dnf)
        EXTRA_DEPS=(gtk2 gtk-murrine-engine)
        ;;
    zypper)
        EXTRA_DEPS=(gtk2-engine-murrine)
        ;;
    xbps-install)
        EXTRA_DEPS=(gtk+2 gtk-murrine-engine)
        ;;
    emerge)
        EXTRA_DEPS=(x11-libs/gtk+:2)
        ;;
    nix-env)
        echo "WARNING: Imperative nix-env install is non-declarative."
        EXTRA_DEPS=()
        ;;
    *)
        EXTRA_DEPS=()
        ;;
esac

install_pkgs "$PM" "${COMMON_DEPS[@]}"
install_pkgs "$PM" "${EXTRA_DEPS[@]}"

echo "Dependency installation complete."
#<--[~|type=script-dep]-->#
