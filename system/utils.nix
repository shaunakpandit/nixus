{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.rsync.enable = true;
  environment.systemPackages = with pkgs; [
    unzip
    unrar
  ];
}
