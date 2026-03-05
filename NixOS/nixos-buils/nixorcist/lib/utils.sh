#!/usr/bin/env bash


get_index_file() {
  echo "$ROOT/cache/nixpkgs-index.txt"
}

ensure_index() {

  local index
  index=$(get_index_file)

  if [[ ! -f "$index" ]]; then
    build_nix_index
  fi
}

get_pkg_description() {
  nix eval --impure --raw --expr "
    let
      pkgs = import <nixpkgs> {};
      val = builtins.tryEval pkgs.${1};
    in
      if val.success && builtins.isAttrs val.value
      then
        (val.value.meta.description or \"No description\")
      else
        \"Not a package\"
  " 2>/dev/null
}

list_available_packages() {
  nix eval --impure --raw --expr '
    let pkgs = import <nixpkgs> {};
        system = builtins.currentSystem or "x86_64-linux";
        set = pkgs.legacyPackages."${system}" or pkgs;
    in builtins.concatStringsSep "\n" (builtins.attrNames set)
  '
}

list_available_packages_lower() {
  list_available_packages | tr '[:upper:]' '[:lower:]'
}

purge_all_modules() {
  rm -f "$MODULES_DIR"/*.nix
  > "$LOCK_FILE"
  echo "Everything purged."
}

# --- package validation ---

is_derivation() {
  nix eval --impure --expr "
    let
      pkgs = import <nixpkgs> {};
      val = pkgs.${1};
    in
      builtins.isAttrs val && (val.type or null) == \"derivation\"
  " 2>/dev/null | grep -q true
}

is_attrset() {
  nix eval --impure --expr "
    let
      pkgs = import <nixpkgs> {};
      val = builtins.tryEval pkgs.${1};
    in
      val.success && builtins.isAttrs val.value &&
      (val.value.type or null) != \"derivation\"
  " 2>/dev/null | grep -q true
}

list_attrset_children() {
  nix eval --impure --raw --expr "
    let
      pkgs = import <nixpkgs> {};
    in
      builtins.concatStringsSep \"\n\" (builtins.attrNames pkgs.${1})
  " 2>/dev/null
}
