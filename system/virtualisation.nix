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
  # Pull before restarting: a host running pihole has no DNS once pihole stops, so the
  # restart must not need the network. set -e skips the restart if any pull fails.
  systemd.services.update-containers = lib.mkIf (containers != { }) {
    description = "Pull updated OCI container images and restart the containers";
    startAt = lib.mkDefault "Tue *-*-* 03:00:00";
    serviceConfig.Type = "oneshot";
    script = ''
      ${lib.concatMapStrings (
        container: "${config.virtualisation.docker.package}/bin/docker pull ${container.image}\n"
      ) (lib.attrValues containers)}
      ${config.systemd.package}/bin/systemctl restart ${
        lib.concatMapStringsSep " " (name: "docker-${name}.service") (lib.attrNames containers)
      }
    '';
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
