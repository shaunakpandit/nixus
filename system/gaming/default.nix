{ config, pkgs, ... }:
{
  imports = [
    ./drivers.nix
    ./steam.nix
    ./runelite.nix
  ];
}
