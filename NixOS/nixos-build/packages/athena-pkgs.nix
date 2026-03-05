{ lib, pkgs, config, ... }:
{
  environment.systemPackages = lib.mkIf config.athena.baseConfiguration (with pkgs; [
    (callPackage ./packages/athena-config-nix/package.nix { })
    (callPackage ./packages/athena-welcome/package.nix { })
    (callPackage ./packages/nist-feed/package.nix { })
  ]);
}
