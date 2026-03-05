{ config, pkgs, ... }:

{
  environment.variables = {
   
  };

  systemd.tmpfiles.rules = [
    "d /var/log/journal 2755 root systemd-journal"
  ];

  services.printing.enable = true;
}
