{ config, lib, ... }:
{
  config.var = {
    hostname = "t14";
    username = "void";
    remap = "caps:ctrl_modifier,altwin:swap_lalt_lwin";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#t14";
    cursorSize = 32;
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
