{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sqlite
    python3
  ];
  programs.devenv = {
    enable = true;
    enableZshIntegration = true;
  };
}
