{ pkgs, lib, ... }:
let
  wlopm = lib.getExe pkgs.wlopm;
in
{
  # Idle inhibitors (e.g. video playback in the browser) pause these timers.
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${wlopm} --off '*'";
        resumeCommand = "${wlopm} --on '*'";
      }
      # Only suspend on battery so long-running jobs on AC aren't interrupted.
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemd-ac-power || ${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events.after-resume = "${wlopm} --on '*'";
  };
}
