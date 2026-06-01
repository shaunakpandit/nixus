{ config, pkgs, ... }:

{
  # udev access for qmk keyboards
  hardware.keyboard.qmk.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", MODE="0660", TAG+="uaccess"
  '';
}
