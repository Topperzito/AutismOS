{ config, pkgs, ... }:
#Personal modular config
{
  imports = [
    ./hardware-configuration.nix

    # ────────────── Boot ──────────────
    ./modules/bootloader.nix
    ./modules/grub-theme.nix
    ./modules/kernel-params.nix

    # ────────────── Display & WM ──────────────
    ./modules/sddm.nix
    ./modules/window-managers.nix

    # ────────────── System Core ──────────────
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/audio.nix
#   ./external/home-manager/nixos
#   ./ZaneyOS/zaneyos/default.nix
    ./modules/environment.nix
    ./modules/zsh.nix
    ./nixorcist/generated/all-packages.nix
  ];

  # ────────────── Fonts ──────────────

  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
  };

  # ────────────── Graphics & Gaming ──────────────

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services.pipewire.enable = true;

  qt = {
    enable = true;
    platformTheme = "kde";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.hyprland.enable = true;
  programs.gamemode.enable = true;

  # ────────────── Global Options ──────────────

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";

  # ────────────── Polkit ──────────────

  security.polkit.enable = true;

  systemd.user.services.polkit-kde-agent = {
    description = "Polkit KDE Authentication Agent";
    after = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  # ────────────── KDE Menu Fix ──────────────

  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # ────────────── Packages ──────────────

  environment.systemPackages =
    (import ./packages/all-packages.nix { inherit pkgs; }) ++ [
      pkgs.kdePackages.polkit-kde-agent-1
      pkgs.kdePackages.kio-admin
      pkgs.hyprland-qt-support

      (pkgs.writeShellScriptBin "nixorcist" ''
        exec /etc/nixos/nixorcist/nixorcist.sh "$@"
      '')
  ];

  system.stateVersion = "25.11";
}
