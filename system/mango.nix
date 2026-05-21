{ config, pkgs, ... }:
{
  programs.mango.enable = true;

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "ghostty.desktop"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ghostty
    cliphist
    wl-clipboard
    grim
    slurp
    swaybg

    brightnessctl
    wireplumber
    playerctl
  ];
}
