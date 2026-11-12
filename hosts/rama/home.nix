{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../home/shell/nvim.nix
    ../../home/shell/shell.nix
    ../../home/shell/dev.nix
    ../../home/shell/utils.nix
    ../../home/mytools
    ./variables.nix
  ];

  home.username = "icarus";
  home.homeDirectory = "/home/icarus";

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
  };

  home.packages = with pkgs; [
    jq
  ];

  home.stateVersion = "26.05";
}
