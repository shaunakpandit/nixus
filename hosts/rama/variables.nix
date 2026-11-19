{ config, lib, ... }:
{
  config.var = {
    hostname = "rama";
    username = "icarus";
    remap = "";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#rama";
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
