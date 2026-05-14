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
    ../../home/nvim.nix
    ../../home/shell.nix
    ../../home/utils.nix
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
