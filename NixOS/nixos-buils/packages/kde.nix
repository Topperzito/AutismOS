{ pkgs }:

with pkgs; [
  kdePackages.discover
  kdePackages.kcalc
  kdePackages.ksystemlog
  kdePackages.breeze
  kdePackages.breeze-gtk
  kdePackages.breeze-icons
  kdePackages.kdeplasma-addons
  kdePackages.plasma-workspace
  kdePackages.plasma-integration
  libsForQt5.qt5ct
  nwg-look
  qt6Packages.qt6ct
  kdePackages.konsole
  kdePackages.dolphin
  kdePackages.kio
  kdePackages.kio-admin
  kdePackages.kio-extras
  kdePackages.kservice
  kdePackages.breeze
  kdePackages.breeze-icons
]
