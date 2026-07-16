{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.rsync.enable = true;
  environment.systemPackages = [
    pkgs.unzip
  ];
}
