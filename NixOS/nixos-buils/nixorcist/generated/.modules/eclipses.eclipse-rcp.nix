{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-rcp
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-rcp
