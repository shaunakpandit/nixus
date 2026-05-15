{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Bootloader.
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      grub = {
        enable = lib.mkForce true;
        efiSupport = lib.mkForce true; # Set to true for UEFI systems
        useOSProber = lib.mkForce true; # Detect Windows and other OSes
        configurationLimit = lib.mkForce 8; # Optional: keep only the latest boot configs
        device = "nodev"; # For UEFI ('nodev'); use actual device for legacy BIOS (e.g., "/dev/sda")
      };
    };
    tmp.cleanOnBoot = true;
    # Silent boot
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
  };

  # To avoid systemd services hanging on shutdown
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
