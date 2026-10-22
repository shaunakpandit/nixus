{ config, pkgs, ... }:
{
  # for nvidia docker containers
  hardware.nvidia-container-toolkit.enable = true;

  virtualisation = {
    oci-containers.backend = "docker";

    # good guide for creating containers https://bkiran.com/blog/deploying-containers-nixos
    docker = {
      enable = true;
      enableOnBoot = true;
      # rootless = {
      #   enable = true;
      #   # allow user to query rootless socket
      #   setSocketVariable = true;
      # };
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      # for nvidia support
      # daemon.settings.features.cdi = true;
    };
  };
}
