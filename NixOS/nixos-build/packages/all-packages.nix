{ pkgs }:

(import ./core.nix { inherit pkgs; }) ++
[ (pkgs.callPackage ./waybar-weather.nix {}) ] ++
(import ./communication.nix { inherit pkgs; }) ++
(import ./hyprland.nix { inherit pkgs; }) ++
(import ./development.nix { inherit pkgs; }) ++
(import ./window-managers.nix { inherit pkgs; }) ++
(import ./games.nix { inherit pkgs; }) ++
(import ./pkg-dump.nix { inherit pkgs; }) ++
(import ./kde.nix { inherit pkgs; })
