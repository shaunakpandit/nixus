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
    profiles.void = {
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
  };

  stylix.targets.firefox.profileName = [ "void" ];

  home.stateVersion = "25.11";
}
