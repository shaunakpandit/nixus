{ config, pkgs, ... }:
{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/profiles/work.nix
    ../../system/laptop.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Only applies to `nixos-rebuild build-vm`, so the throwaway password never reaches real hardware.
  virtualisation.vmVariant = {
    users.users.${config.var.username}.initialPassword = "test";
    virtualisation = {
      memorySize = 8192;
      cores = 4;
      qemu.options = [
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };
  };

  system.stateVersion = "25.11"; # Matches t14 for test-booting; use the installer's value on the real machine.
}
