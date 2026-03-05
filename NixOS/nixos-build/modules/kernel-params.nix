{ config, pkgs, lib, ... }:

{
  ############################
  # Kernel behavior
  ############################

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.panic" = 10;

    # Laptop tuning
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  ############################
  # Intel GPU tuning (T480 friendly)
  ############################

  boot.kernelParams = [
    "i915.enable_guc=3"   # enable GuC + HuC firmware
    "i915.fastboot=1"     # faster display init
    "i915.enable_fbc=1"   # framebuffer compression (lower idle power)
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # useful even if you don’t game
  };

  ############################
  # CPU microcode
  ############################

  hardware.cpu.intel.updateMicrocode = true;

  ############################
  # Power management (Plasma-native)
  ############################

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;  # avoid conflict

  ############################
  # Firmware
  ############################

  hardware.enableRedistributableFirmware = true;
}
