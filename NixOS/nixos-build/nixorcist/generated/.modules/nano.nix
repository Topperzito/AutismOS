{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nano
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: nano
