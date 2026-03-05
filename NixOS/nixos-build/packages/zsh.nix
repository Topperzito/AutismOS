{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Optional: set your preferred zsh theme, e.g., powerlevel10k
    # You may need to package powerlevel10k or install it manually if not in nixpkgs
    # promptInit = "${pkgs.powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

    # Optional: custom .zshrc fragment if you want to add extra config
    # initExtra = ''
    #   source ${pkgs.someZshPlugin}/share/plugin.zsh
    # '';
  };

  # Optionally install oh-my-zsh or custom plugins
  # environment.systemPackages = [ pkgs.zsh ];
}
