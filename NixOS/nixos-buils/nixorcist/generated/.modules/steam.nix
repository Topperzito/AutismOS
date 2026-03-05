{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    steam
  ];
}

#$nixorcist$#
# NIXORCIST-ATTRPATH: steam
