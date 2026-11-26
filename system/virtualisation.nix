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

  # "8089:80/tcp", "127.0.0.1:2375:2375" or "25500-25600:25500-25600/udp" -> the host side.
  # shortcut: specs without a host port ("8080") or with IPv6 addresses are skipped; parse them if one appears.
  hostSide =
    spec:
    let
      parts = lib.splitString "/" spec;
      fields = lib.splitString ":" (lib.head parts);
      count = lib.length fields;
      bounds = map lib.toInt (lib.splitString "-" (lib.elemAt fields (count - 2)));
    in
    lib.optional (count == 2 || (count == 3 && !lib.hasPrefix "127." (lib.head fields))) {
      protocol = if lib.length parts == 2 then lib.last parts else "tcp";
      from = lib.head bounds;
      to = lib.last bounds;
    };
  published = lib.concatMap hostSide (
    lib.concatMap (container: container.ports) (lib.attrValues containers)
  );
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
