{ config, lib, ... }:
{
  config.var = {
    hostname = "d4080";
    username = "void";
    remap = "";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#d4080";
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
