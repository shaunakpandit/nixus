{ config, pkgs, ... }:
let
  # cliamp only reads the plex token from config.toml, so sops renders the whole file at activation.
  settings = {
    provider = "plex";
    volume = 0;
    volume_min = -50;
    repeat = "off";
    shuffle = false;
    mono = false;
    initial_directory = "~/Music";
    seek_large_step_sec = 30;
    eq_preset = "Custom";
    # EQ is done on the master output by easyeffects. The ie200 short nozzle preset, if ever needed:
    # [ 1.1 (-0.9) (-0.6) 0.5 0.2 1.7 1.9 (-6.4) (-8.6) (-10.6) ]
    eq = [
      0
      0
      0
      0
      0
      0
      0
      0
      0
      0
    ];
    # also good: Stereo, Pulse, Scope, Heartbeat, ClassicLED
    visualizer = "Wave";
    vis_volume_linked = true;
    low_power = false;
    compact = false;
    # generated from the stylix palette in home/shell/cliamp.nix
    theme = "Stylix";
    log_level = "info";
    plex = {
      url = "http://192.168.4.28:32400";
      token = config.sops.placeholder.plex_token;
    };
  };
in
{
  sops.secrets.plex_token = { };
  sops.templates."cliamp-config.toml" = {
    owner = config.var.username;
    path = "/home/${config.var.username}/.config/cliamp/config.toml";
    file = (pkgs.formats.toml { }).generate "cliamp-config.toml" settings;
  };
}
