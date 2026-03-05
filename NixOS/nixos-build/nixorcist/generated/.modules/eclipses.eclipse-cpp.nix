{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-cpp
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-cpp
