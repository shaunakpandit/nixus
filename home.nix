{ config, pkgs, ... }:
{
  imports = [
    ./home/nvim.nix
    ./home/shell.nix
    ./home/mango
  ];

  home.username = "void";
  home.homeDirectory = "/home/void";

  home.packages = with pkgs; [
    lua-language-server
    nil
    nixpkgs-fmt
    nodejs

    waybar
    wmenu
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
