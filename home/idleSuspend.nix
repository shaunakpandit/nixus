{
  config,
  pkgs,
  lib,
  ...
}:
let
  systemd = "${pkgs.systemd}/bin";
in
{
  imports = [ ./idle.nix ];

  services.swayidle.timeouts = [
    {
      timeout = 900;
      # Laptops only suspend on battery so long-running jobs on AC aren't
      # interrupted. Desktops have no battery, and systemd-ac-power reports AC there.
      command =
        lib.optionalString (config.var.suspendOnBatteryOnly or false) "${systemd}/systemd-ac-power || "
        + "${systemd}/systemctl suspend";
    }
  ];
}
