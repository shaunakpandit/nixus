{
  config,
  pkgs,
  inputs,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{
  imports = [
    ../../home/mango
    ../../home/helium.nix
    ../../home/firefox.nix
    ../../home/waybar.nix
    ../../home/easyeffects.nix
    ../../home/fuzzel.nix
    ../../home/feh.nix
    ../../home/tradingview.nix
    ../../home/sioyek.nix
    ../../home/games/chess.nix
    ../../home/shell/shell.nix
    ../../home/shell/utils.nix
    ../../home/shell/cliamp.nix
    ../../home/shell/dev.nix
    ../../home/shell/nvim.nix
    ./variables.nix
  ];

  home.username = "void";
  home.homeDirectory = "/home/void";

  # to add binaries to path
  # home.sessionPath = [
  #   "$HOME/.local/bin"
  #   "$HOME/bin"
  #   "$HOME/.nix-profile/bin"
  # ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
  };

  home.packages = with pkgs; [
    jq
  ];

  home.stateVersion = "25.11";
}
