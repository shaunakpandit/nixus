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
    ../../home/shell/nvim.nix
    ../../home/shell/shell.nix
    ../../home/shell/utils.nix
  ];

  home.username = "hugh";
  home.homeDirectory = "/home/hugh";

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
