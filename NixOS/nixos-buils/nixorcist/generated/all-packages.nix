{ config, pkgs, ... }:
{
  imports = [
    ./.modules/eclipses.eclipse-committers.nix
    ./.modules/eclipses.eclipse-cpp.nix
    ./.modules/eclipses.eclipse-dsl.nix
    ./.modules/eclipses.eclipse-embedcpp.nix
    ./.modules/eclipses.eclipse-java.nix
    ./.modules/eclipses.eclipse-jee.nix
    ./.modules/eclipses.eclipse-modeling.nix
    ./.modules/eclipses.eclipse-platform.nix
    ./.modules/eclipses.eclipse-rcp.nix
    ./.modules/eclipses.eclipse-sdk.nix
    ./.modules/nano.nix
    ./.modules/steam.nix
    ./.modules/swww.nix
    ./.modules/wallust.nix
  ];
}
