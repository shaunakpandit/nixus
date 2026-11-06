{ config, lib, ... }:
{
  config.var = {
    hostname = "rama";
    username = "icarus";
    remap = "";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#rama";
    cursorSize = 36;
    homelab = {
      rama = "192.168.4.29";
    };
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
