{ config, lib, ... }:

let
  blocklists = [
    "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
    "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
  ];
in
{
  # Pi-hole v6 keeps subscribed lists in gravity.db rather than pihole.toml, so FTLCONF_ can't set them.
  systemd.services.pihole-blocklists = {
    description = "Subscribe pihole to declared blocklists";
    after = [ "docker-pihole.service" ];
    bindsTo = [ "docker-pihole.service" ];
    # Not RemainAfterExit, so every (re)start of pihole pulls this in again.
    wantedBy = [ "docker-pihole.service" ];
    path = [ config.virtualisation.docker.package ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "15min";
    };
    # Healthy means first-run gravity has finished, so ours won't race it.
    script = ''
      until [ "$(docker inspect -f '{{.State.Health.Status}}' pihole 2>/dev/null)" = healthy ]; do sleep 5; done
      changed=$(docker exec pihole pihole-FTL sqlite3 /etc/pihole/gravity.db \
        "INSERT OR IGNORE INTO adlist (address) VALUES ${
          lib.concatMapStringsSep ", " (url: "('${url}')") blocklists
        }; SELECT total_changes();")
      if [ "$changed" -gt 0 ]; then docker exec pihole pihole -g; fi
    '';
  };

  # While pihole is down (restart, update, crash), a host that only resolves through itself has no
  # DNS, so image pulls fail and pihole may never come back (the "tech tuesday" outage).
  # shortcut: the host's own tailscale IP isn't known at eval time, so it would pass as a fallback.
  assertions = [
    {
      assertion = lib.any (
        server:
        !(
          lib.hasPrefix "127." server
          || lib.elem server [
            "::1"
            "localhost"
            (config.var.homelab.${config.var.hostname} or "")
          ]
        )
      ) (config.networking.nameservers ++ config.networking.networkmanager.insertNameservers);
      message = "containers/pihole.nix: ${config.var.hostname} resolves only through its own pihole. Add an outside fallback, e.g. networking.networkmanager.insertNameservers = [ \"127.0.0.1\" \"1.1.1.1\" ].";
    }
  ];

  systemd.tmpfiles.rules = [ "d /var/lib/pihole 0755 root root -" ];

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    # No pull: a restart while the internet is down would leave the LAN without DNS. Update by hand.
    environment = {
      TZ = config.time.timeZone;
      # Unbound from containers/unbound.nix, reached through its published host port.
      FTLCONF_dns_upstreams = "${config.var.homelab.${config.var.hostname}}#5335";
      # Bridge networking hides that LAN/tailnet clients are local, so answer everyone.
      FTLCONF_dns_listeningMode = "all";
      # Empty disables web/API auth; unset, pihole generates a random password.
      FTLCONF_webserver_api_password = "";
    };
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "8089:80/tcp" # web ui, port 80 is left for traefik
    ];
    volumes = [ "/var/lib/pihole:/etc/pihole" ];
  };
}
