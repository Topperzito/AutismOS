#!/usr/bin/env bash

is_derivation() {
  nix eval --impure --raw --expr "
    let
      pkgs = import <nixpkgs> {};
      val = builtins.tryEval pkgs.${1};
    in
      if val.success then
        if builtins.isAttrs val.value && (val.value.type or null) == \"derivation\"
        then \"true\"
        else \"false\"
      else
        \"false\"
  " 2>/dev/null | grep -q true
}

generate_modules() {
  echo "Generating modules from lock..."

  mapfile -t packages < <(read_lock_entries)

  for pkg in "${packages[@]}"; do

    # Validate package exists AND is derivation
    if ! is_derivation "$pkg"; then
      echo "Skipping non-package: $pkg"
      continue
    fi

    safe_name=$(echo "$pkg" | tr '/' '-' | tr ' ' '_' | tr ':' '_')
    target="$MODULES_DIR/$safe_name.nix"

    if [[ -f "$target" ]]; then
      echo "exists: $safe_name.nix"
      continue
    fi

    cat > "$target" <<EOF
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    $pkg
  ];
}

$NIXORCIST_MARKER
# NIXORCIST-ATTRPATH: $pkg
EOF

    echo "spawned: $safe_name.nix"
  done
}
