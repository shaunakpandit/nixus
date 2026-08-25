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
    ./variables.nix
    ../../home/mango
    ../../home/ghostty.nix
    ../../home/firefox.nix
    ../../home/helium.nix
    ../../home/waybar.nix
    ../../home/fuzzel.nix
    ../../home/sioyek.nix
    ../../home/shell/shell.nix
    ../../home/shell/utils.nix
    ../../home/shell/cliamp.nix
    ../../home/shell/dev.nix
    ../../home/shell/nvim.nix
    ../../home/games/prism.nix
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
