{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wallust
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: wallust
