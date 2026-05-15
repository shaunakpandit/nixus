{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./drivers.nix
    ./steam.nix
    ./runelite.nix
  ];
}
