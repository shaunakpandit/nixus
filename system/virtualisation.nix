{ pkgs, ... }: {
  # for nvidia docker containers
  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    rootless = {
      enable = true;
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
