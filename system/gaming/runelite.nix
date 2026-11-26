{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.runelite
  ];
}
