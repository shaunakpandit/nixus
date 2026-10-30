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
  services.tlp = {
    enable = true;

    settings = {
      # CPU policy
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Supported on many recent ThinkPads.
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Adaptive backlight modulation: dims the panel on dark content and
      # boosts contrast to compensate. Lower it if colors look washed out.
      AMDGPU_ABM_LEVEL_ON_AC = 0;
      AMDGPU_ABM_LEVEL_ON_BAT = 3;

      DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth nfc wwan";

      # Device power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
    };
  };
  # services.auto-cpufreq = {
  #   enable = true;
  #   settings = {
  #     battery = {
  #       governor = "powersave";
  #       turbo = "never";
  #     };
  #     charger = {
  #       governor = "perfomance";
  #       turbo = "auto";
  #     };
  #   };
  # };
}
