{ config, pkgs, ... }:
{
  imports = [
    ./home/nvim.nix
    ./home/shell.nix
    ./home/stylix.nix
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
  };

  home.stateVersion = "25.11";
}
