{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-embedcpp
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-embedcpp
