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
    ];
    events.after-resume = "${wlopm} --on '*'";
  };
}
