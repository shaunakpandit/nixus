{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sqlite
    devenv
    python3
  ];
}
