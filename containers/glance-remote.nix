{ ... }:

# Endpoints for thoth's glance (containers/monitoring.nix) to read this host's stats and containers.
{
  virtualisation.oci-containers.containers = {
    glance-agent = {
      image = "glanceapp/agent:latest";
      pull = "always";
      # The container's / is overlayfs on the host root, so it reports the host's root disk.
      environment = {
        HIDE_MOUNTPOINTS_BY_DEFAULT = "true";
        MOUNTPOINTS = "/";
      };
      ports = [ "27973:27973" ];
    };

    # Read-only Docker API (container list only) instead of exposing the socket itself.
    docker-socket-proxy = {
      image = "tecnativa/docker-socket-proxy:latest";
      pull = "always";
      environment.CONTAINERS = "1";
      ports = [ "2375:2375" ];
      volumes = [ "/var/run/docker.sock:/var/run/docker.sock:ro" ];
    };
  };
}
