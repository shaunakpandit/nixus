{ config, pkgs, ... }:
{
  import = [
    ./drivers.nix
    ./steam.nix
    ./runelite.nix
  ];
}
