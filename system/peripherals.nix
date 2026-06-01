{ config, pkgs, ... }:

{
  # udev access for qmk keyboards
  hardware.keyboard.qmk.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="6582", ATTRS{idProduct}=="0025", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="6582", ATTR{idProduct}=="0025", MODE="0660", TAG+="uaccess"
  '';

  # use
  # sudo udevadm control --reload-rules
  # sudo udevadm trigger
  # after setting rule to refresh
}
