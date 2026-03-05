#!/usr/bin/env bash

regenerate_hub() {
  HUB="$ROOT/generated/all-packages.nix"

  echo "Regenerating hub..."

  mkdir -p "$ROOT/generated"

  {
    echo "{ config, pkgs, ... }:"
    echo "{"
    echo "  imports = ["

    for f in "$MODULES_DIR"/*.nix; do
      [ -e "$f" ] || continue
      echo "    ./.modules/$(basename "$f")"
    done

    echo "  ];"
    echo "}"
  } > "$HUB"

  echo "hub regenerated."
}
