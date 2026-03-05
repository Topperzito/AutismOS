{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Optional: only if you're using the system to *explicitly* point to your .zshrc (not necessary, but harmless)
#    interactiveShellInit = ''
#      if [ -f "${config.users.users.tak_1.home}/.zshrc" ]; then
#        source "${config.users.users.tak_1.home}/.zshrc"
#      fi
#    '';
  };
}
