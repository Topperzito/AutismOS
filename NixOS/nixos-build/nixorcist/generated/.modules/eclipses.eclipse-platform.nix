{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-platform
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-platform
