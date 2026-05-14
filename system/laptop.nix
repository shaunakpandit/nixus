{ config, pkgs, ... }:
{
  hardware.trackpoint = {
    enable = true;
    sensitivity = 50;
    speed = 25;
    inertia = 2;
  };

  ## POWER
  powerManagement.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "perfomance";
        turbo = "auto";
      };
    };
  };
}
