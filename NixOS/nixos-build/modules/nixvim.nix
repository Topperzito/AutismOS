{ pkgs, ... }:

{
  environment.systemPackages = [
    (import /etc/nixos/external/nixvim { inherit pkgs; })
  ];
}
