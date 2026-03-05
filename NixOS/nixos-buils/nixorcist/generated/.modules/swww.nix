{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swww
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: swww
