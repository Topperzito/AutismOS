{ pkgs }:

let
  dir = ./.modules;

  files =
    builtins.filter
      (name: builtins.match ".*\\.nix" name != null)
      (builtins.attrNames (builtins.readDir dir));
in

map
  (name: import (dir + "/${name}") { inherit pkgs; })
  files
