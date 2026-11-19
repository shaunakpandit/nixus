{ config, lib, ... }:
{
  config.var = {
    hostname = "thea";
    username = "shaunak";
    remap = "caps:ctrl_modifier,altwin:swap_lalt_lwin";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#thea";
    suspendOnBatteryOnly = true;
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
