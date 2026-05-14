{ config, pkgs, ... }:
{
  hardware.trackpoint = {
    enable = true;
    sensitivity = 100;
    speed = 50;
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
