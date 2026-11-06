{
  config,
  lib,
  pkgs,
  ...
}:
let
  containers = config.virtualisation.oci-containers.containers;
in
{
  # Containers only pull (pull = "always") when their service starts, so restart them weekly to update.
  systemd.services.update-containers = lib.mkIf (containers != { }) {
    description = "Restart OCI containers to pull updated images";
    startAt = lib.mkDefault "Tue *-*-* 03:00:00";
    serviceConfig.Type = "oneshot";
    script = "${config.systemd.package}/bin/systemctl restart ${
      lib.concatMapStringsSep " " (name: "docker-${name}.service") (lib.attrNames containers)
    }";
  };

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
