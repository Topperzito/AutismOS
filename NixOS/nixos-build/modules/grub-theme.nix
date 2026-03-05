{ config, pkgs, ... }:

{
  # example GRUB tweak
  boot.loader.grub.configurationLimit = 10;
}
