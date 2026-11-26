# Per-host values, set in hosts/<host>/variables.nix and read as config.var.* by NixOS and
# home-manager modules alike. Typed, so a misspelled or missing value fails evaluation.
{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.var = {
    hostname = mkOption { type = types.str; };
    username = mkOption { type = types.str; };
    # xkb_rules_options for mango, e.g. "caps:ctrl_modifier".
    remap = mkOption {
      type = types.str;
      default = "";
    };
    suspendOnBatteryOnly = mkOption {
      type = types.bool;
      default = false;
    };
    rebuildCommand = mkOption {
      type = types.str;
      default = "sudo nixos-rebuild switch --flake ~/dev/nixus#${config.var.hostname}";
    };
    # LAN addresses; use config.var.homelab.<name> instead of hardcoding them.
    homelab = mkOption {
      type = types.attrsOf (types.either types.str types.port);
      default = import ./homelab.nix;
    };
  };
}
