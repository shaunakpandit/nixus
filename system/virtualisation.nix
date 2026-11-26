# Docker and OCI containers, for servers and work laptops.
{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  containers = config.virtualisation.oci-containers.containers;
  fileDefining =
    name:
    (lib.findFirst (definition: definition.value ? ${name}) {
      file = null;
    } options.virtualisation.oci-containers.containers.definitionsWithLocations).file;
  filesOpeningPorts = map (definition: definition.file) (
    lib.filter (definition: definition.value != [ ]) (
      options.networking.firewall.allowedTCPPorts.definitionsWithLocations
      ++ options.networking.firewall.allowedUDPPorts.definitionsWithLocations
    )
  );
in
{
  # Host-network containers skip Docker's port publishing (which bypasses the firewall), so the
  # file defining one must open its ports itself, as containers/plex.nix does.
  assertions = lib.mapAttrsToList (name: container: {
    assertion =
      !(lib.elem "--network=host" container.extraOptions || lib.elem "host" container.networks)
      || lib.elem (fileDefining name) filesOpeningPorts;
    message = "${fileDefining name}: container ${name} uses host networking, so open its ports with networking.firewall in that file.";
  }) containers;

  # Containers only pull (pull = "always") when their service starts, so restart them weekly to update.
  systemd.services.update-containers = lib.mkIf (containers != { }) {
    description = "Restart OCI containers to pull updated images";
    startAt = lib.mkDefault "Tue *-*-* 03:00:00";
    serviceConfig.Type = "oneshot";
    script = "${config.systemd.package}/bin/systemctl restart ${
      lib.concatMapStringsSep " " (name: "docker-${name}.service") (lib.attrNames containers)
    }";
  };

  users.users.${config.var.username}.extraGroups = [ "docker" ];
  environment.systemPackages = [ pkgs.docker-compose ];

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
