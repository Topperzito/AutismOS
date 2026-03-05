{ lib, ... }:

let
  zaneySrc = /etc/nixos/ZaneyOS/src;
in
{
  imports = [
    "${zaneySrc}/modules/core/greetd.nix"
  ];
}
