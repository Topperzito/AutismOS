{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eclipses.eclipse-java
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: eclipses.eclipse-java
