# Graphical machines running mango. Pair with home/profiles/desktop.nix.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./base.nix
    ../audio.nix
    ../mango.nix
    ../peripherals.nix
    # Writes browser policies for users who import home/helium.nix; does nothing otherwise.
    inputs.helium.nixosModules.helium
  ];

  users.users.${config.var.username}.packages = with pkgs; [
    kdePackages.dolphin
    plexamp
  ];

  environment.systemPackages = with pkgs; [
    xdg-utils
    wev
  ];
}
