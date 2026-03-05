# users.nix
{ config, pkgs, ... }:

{
  users.users.tak_1 = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Elder Evil";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      pkgs.zsh
    ];
  };
}
