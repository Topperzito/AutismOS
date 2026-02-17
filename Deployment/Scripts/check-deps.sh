#!/usr/bin/env bash
set -euo pipefail

need_cmd() {
    command -v "$1" >/dev/null 2>&1
}

install_jq() {
    echo "jq not found. Attempting installation..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
    else
        echo "Cannot detect OS."
        exit 1
    fi

    case "${ID,,}" in
        arch)
            sudo pacman -Sy --noconfirm jq
            ;;
        debian|ubuntu|linuxmint)
            sudo apt update
            sudo apt install -y jq
            ;;
        fedora)
            sudo dnf install -y jq
            ;;
        opensuse*|suse)
            sudo zypper install -y jq
            ;;
        void)
            sudo xbps-install -Sy jq
            ;;
        gentoo)
            sudo emerge app-misc/jq
            ;;
        nixos)
            echo "On NixOS. Installing jq via nix profile..."
            nix profile install nixpkgs#jq
            ;;
        *)
            echo "Unsupported distribution: $ID"
            exit 1
            ;;
    esac
}

if need_cmd jq; then
    echo "jq already installed."
else
    install_jq
fi
