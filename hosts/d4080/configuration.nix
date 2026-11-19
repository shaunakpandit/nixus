{ config, pkgs, ... }:
{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/profiles/desktop.nix
    ../../system/nvidia.nix
    ../../system/cachyos.nix
    ../../system/fail2ban.nix
    ../../system/gaming
    ../../system/gaming/performance.nix
    ../../system/gaming/starcitizen.nix
  ];

  # what CachyOS installs on Zen 4: ThinLTO and -march=znver4.
  # The kernel is cached but the nvidia module for it builds locally
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

  users.users.${config.var.username}.extraGroups = [ "input" ];

  fonts.packages = with pkgs; [
    nerd-fonts.lilex
  ];

  system.stateVersion = "25.11"; # Release of the first install; never change it.
}
