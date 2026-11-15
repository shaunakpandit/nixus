{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.libmtp ];
  # The default output is -bin, which has no udev rules.
  services.udev.packages = [ pkgs.libmtp.out ];
  # libmtp's rules tag devices for uaccess, which only covers local seats; thoth is used over SSH.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", MODE="0660", GROUP="users"
  '';
}
