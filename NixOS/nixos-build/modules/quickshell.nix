{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.callPackage /etc/nixos/external/quickshell {}
  ];
}
