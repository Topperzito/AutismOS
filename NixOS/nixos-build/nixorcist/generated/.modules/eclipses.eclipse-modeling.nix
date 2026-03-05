{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-modeling
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-modeling
