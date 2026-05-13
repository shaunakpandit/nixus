{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.runelite
  ];
}
