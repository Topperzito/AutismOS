{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-sdk
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-sdk
