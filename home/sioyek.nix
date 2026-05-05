{ config, lib, ... }:
{
  programs.sioyek = {
    enable = true;
    config = {
      startup_commands = [
        "toggle_dark_mode"
      ];
    };
  };
}
