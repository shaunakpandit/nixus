{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.rsync.enable = true;
  environment.systemPackages = with pkgs; [
    # File compression
    unzip
    unrar

    # Image modification
    gowall
  ];
}
