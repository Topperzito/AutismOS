#!/usr/bin/env bash

INDEX_DIR="$ROOT/cache"
INDEX_FILE="$INDEX_DIR/nixpkgs-index.txt"

build_nix_index() {

  echo "Building nixpkgs index..."

  mkdir -p "$INDEX_DIR"

  nix eval --impure --raw --expr '
    let
      pkgs = import <nixpkgs> {};
      names = builtins.attrNames pkgs;

      format = name:
        let
          val = builtins.tryEval pkgs.${name};
        in
          if val.success && builtins.isAttrs val.value then
            name + "|" + (val.value.meta.description or "")
          else
            name + "|";
    in
      builtins.concatStringsSep "\n" (map format names)
  ' > "$INDEX_FILE"

  echo "Index written to $INDEX_FILE"
}
