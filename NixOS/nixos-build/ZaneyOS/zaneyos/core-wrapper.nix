{ lib, ... }:

let
  zaneySrc = /etc/nixos/ZaneyOS/src;
in
{
  imports = [
    "${zaneySrc}/modules/core/fonts.nix"
    "${zaneySrc}/modules/core/network.nix"
    "${zaneySrc}/modules/core/packages.nix"
    "${zaneySrc}/modules/core/services.nix"
    # list all core modules statically
  ];
}
