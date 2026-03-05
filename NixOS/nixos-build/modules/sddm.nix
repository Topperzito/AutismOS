{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sddm-sugar-dark
  ];

services.displayManager.sddm.theme = "elarun";
}
