#!/usr/bin/env bash
set -euo pipefail

echo "{ pkgs, ... }:"
echo "{"
echo "  environment.systemPackages = with pkgs; ["

# Example detection (replace with your logic)
nix-env -q | awk '{print "    " $1}'

echo "  ];"
echo "}"
