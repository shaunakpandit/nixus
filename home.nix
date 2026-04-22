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
  ];

  home.stateVersion = "25.11";
}
