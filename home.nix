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
    ./home/nvim.nix
    ./home/shell.nix
    ./home/mango
    ./home/utils.nix
    ./home/firefox.nix
    ./home/waybar.nix
  ];

  home.username = "void";
  home.homeDirectory = "/home/void";

  # to add binaries to path
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.nix-profile/bin"
  ];

  home.packages = with pkgs; [
    jq
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        icons-enabled = false;
        anchor = "top";
        lines = 7;
        horiozontal-pad = 12;
        vertical-pad = 4;
      };
      border = {
        radius = 0;
      };
      key-bindings = {
        next-with-wrap = "Control+j";
        prev-with-wrap = "Control+k";
      };
    };
  };

  home.stateVersion = "25.11";
}
