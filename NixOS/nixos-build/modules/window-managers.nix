{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.xserver.windowManager = {
    bspwm.enable = true;
    i3.enable = true;
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
