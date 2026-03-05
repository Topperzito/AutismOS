{ lib, ... }:

{
  options.zaneyos = {
    enable = lib.mkEnableOption "Enable ZaneyOS layer";

    driver = lib.mkOption {
      type = lib.types.enum [ "amd" "nvidia" "intel" "vm" ];
      default = "intel";
      description = "Select GPU driver profile";
    };

    display.enable = lib.mkEnableOption "Enable display layer";

    core.enable = lib.mkEnableOption "Enable core layer";
  };
}
