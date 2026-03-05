{ config, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.panic" = 10;
  };

  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.stable ];

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
    prime.sync.enable = true;
  };

  # Ensure modules are loaded in initrd stage
  boot.initrd.availableKernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  # Cold boot GPU fix (PCI rescan + rebind)
  boot.initrd.preDeviceCommands = ''
    echo "[Initrd] Triggering PCI rescan"
    echo 1 > /sys/bus/pci/rescan

    GPU="0000:01:00.0"  # 🔁 Replace with your actual GPU PCI ID
    echo $GPU > /sys/bus/pci/drivers/nvidia/unbind || true
    sleep 0.5
    echo $GPU > /sys/bus/pci/drivers/nvidia/bind || true

    echo "[Initrd] NVIDIA GPU rebind completed"
  '';
}
