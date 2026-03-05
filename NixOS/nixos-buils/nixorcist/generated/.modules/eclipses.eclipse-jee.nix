{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-jee
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-jee
