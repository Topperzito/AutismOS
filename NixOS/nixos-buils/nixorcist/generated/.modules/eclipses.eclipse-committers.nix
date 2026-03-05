{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-committers
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-committers
