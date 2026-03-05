{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-dsl
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-dsl
