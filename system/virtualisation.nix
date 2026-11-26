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
      ++ options.networking.firewall.allowedTCPPortRanges.definitionsWithLocations
      ++ options.networking.firewall.allowedUDPPortRanges.definitionsWithLocations
    )
  );

  inherit (import ../ports.nix { inherit lib; }) publishedPort;
  published = lib.filter (port: !port.hostOnly) (
    lib.concatMap publishedPort (lib.concatMap (container: container.ports) (lib.attrValues containers))
  );
  hostNetwork =
    container:
    lib.any (option: lib.elem option container.extraOptions) [
      "--network=host"
      "--net=host"
    ]
    || lib.elem "host" container.networks;
  # Containers that update themselves; the rest (pihole, unbound) are updated by hand.
  pulling = lib.filterAttrs (_: container: container.pull == "always") containers;
  rangesFor =
    protocol:
    map (port: { inherit (port) from to; }) (lib.filter (port: port.protocol == protocol) published);
in
{
  # Docker steers LAN traffic for published ports around this firewall, but a container reaching
  # another through the host's address (glance's checks, pihole -> unbound) goes through it.
  networking.firewall.allowedTCPPortRanges = rangesFor "tcp";
  networking.firewall.allowedUDPPortRanges = rangesFor "udp";

  # Host-network containers skip Docker's port publishing, so the file defining one must open its
  # ports itself, as containers/plex.nix does.
  assertions = lib.mapAttrsToList (name: container: {
    assertion = !(hostNetwork container) || lib.elem (fileDefining name) filesOpeningPorts;
    message = "${fileDefining name}: container ${name} uses host networking, so open its ports with networking.firewall in that file.";
  }) containers;

  # Containers only pull (pull = "always") when their service starts, so restart those weekly to update.
  systemd.services.update-containers = lib.mkIf (pulling != { }) {
    description = "Restart OCI containers to pull updated images";
    startAt = lib.mkDefault "Tue *-*-* 03:00:00";
    serviceConfig.Type = "oneshot";
    script = "${config.systemd.package}/bin/systemctl restart ${
      lib.concatMapStringsSep " " (name: "docker-${name}.service") (lib.attrNames pulling)
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
