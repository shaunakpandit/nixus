{ config, pkgs, ... }:
{
  imports = [
    ./home/nvim.nix
    ./home/shell.nix
    ./home/mango
    ./home/utils.nix
  ];

  home.username = "void";
  home.homeDirectory = "/home/void";

  home.packages = with pkgs; [
    waybar
    wmenu
    jq
  ];

  programs.waybar = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    profiles = {
      void = {
        isDefault = true;
        extensions = {
          force = true;
        };
        settings = {
          # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
  };

  stylix.targets.firefox = {
    enable = true;
    colorTheme.enable = true;
    colors.enable = true;
    fonts.enable = true;
    profileNames = [ "void" ];
  };

  home.stateVersion = "25.11";
}
