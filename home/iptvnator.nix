{ pkgs, ... }:
{
  home.packages = with pkgs; [
    iptvnator
  ];
}
