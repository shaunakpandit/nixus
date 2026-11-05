{ config, ... }:

{
  systemd.tmpfiles.rules = [ "d /var/lib/pihole 0755 root root -" ];

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    pull = "always";
    environment = {
      TZ = config.time.timeZone;
      # Unbound from containers/unbound.nix, reached through its published host port.
      FTLCONF_dns_upstreams = "${config.var.homelab.${config.var.hostname}}#5335";
      # Bridge networking hides that LAN/tailnet clients are local, so answer everyone.
      FTLCONF_dns_listeningMode = "all";
    };
    # Keep the admin password outside the world-readable Nix store.
    # Create /etc/pihole.env containing FTLCONF_webserver_api_password=
    environmentFiles = [ "/etc/pihole.env" ];
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "8089:80/tcp" # web ui, port 80 is left for traefik
    ];
    volumes = [ "/var/lib/pihole:/etc/pihole" ];
  };
}
