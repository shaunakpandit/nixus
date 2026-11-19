{ config, lib, ... }:
{
  config.var = {
    hostname = "thoth";
    username = "hugh";
    remap = "";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#thoth";
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
