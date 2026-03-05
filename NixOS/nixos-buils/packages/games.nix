{ pkgs }:

with pkgs; [
  
  
  obs-studio
  mangohud
  steam
    mesa
  vulkan-loader
  vulkan-tools
  vulkan-validation-layers
  # 32-bit Vulkan:
  pkgsi686Linux.mesa
  pkgsi686Linux.vulkan-loader
]
