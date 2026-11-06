{ config, lib, ... }:
{
  config.var = {
    hostname = "thoth";
    username = "hugh";
    remap = "";
    rebuildCommand = "sudo nixos-rebuild switch --flake ~/dev/nixus#thoth";
    cursorSize = 36;
    homelab = {
      thoth = "192.168.4.28";
      rama = "192.168.4.29";
      pihole = "192.168.4.25";
      piholePort = 8089;
      traefik = "192.168.4.26";
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
