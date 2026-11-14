{ config, lib, ... }:

let
  mediaDir = "/mnt/media";

  # linuxserver.io images and their web ui ports. They reach qbittorrent at the host IP, port 8080.
  arrs = {
    prowlarr = 9696; # indexers for everything below
    sonarr = 8989; # tv
    radarr = 7878; # movies
    lidarr = 8686; # music
    lazylibrarian = 5299; # books and audiobooks; readarr is retired
    bazarr = 6767; # subtitles for sonarr/radarr
  };

  linuxserver = name: {
    image = "lscr.io/linuxserver/${name}:latest";
    pull = "always";
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = config.time.timeZone;
    };
    # One /data mount for downloads and library, so imports are hardlinks instead of copies.
    volumes = [
      "/var/lib/${name}:/config"
      "${mediaDir}:/data"
    ];
  };

  mediaContainers = lib.attrNames arrs ++ [ "qbittorrent" ];
in
{
  systemd.tmpfiles.rules =
    map (name: "d /var/lib/${name} 0750 1000 100 -") ([ "gluetun" ] ++ mediaContainers)
    ++ map (dir: "d ${mediaDir}/${dir} 0775 1000 100 -") [
      "torrents"
      "torrents/tv"
      "torrents/movies"
      "torrents/music"
      "torrents/books"
    ];

  virtualisation.oci-containers.containers =
    lib.mapAttrs (
      name: port:
      linuxserver name
      // {
        ports = [ "${toString port}:${toString port}" ];
      }
    ) arrs
    // {
      # ProtonVPN, because it supports port forwarding for seeding (mullvad dropped it).
      # /etc/gluetun.env holds WIREGUARD_PRIVATE_KEY, kept out of the Nix store.
      gluetun = {
        image = "qmcgaw/gluetun:latest";
        pull = "always";
        environment = {
          TZ = config.time.timeZone;
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          VPN_PORT_FORWARDING = "on";
          PORT_FORWARD_ONLY = "on";
          # Needs qbittorrent's "bypass authentication for clients on localhost".
          VPN_PORT_FORWARDING_UP_COMMAND = ''/bin/sh -c 'wget -O- --retry-connrefused --post-data "json={\"listen_port\":{{PORT}},\"current_network_interface\":\"{{VPN_INTERFACE}}\",\"random_port\":false,\"upnp\":false}" http://127.0.0.1:8080/api/v2/app/setPreferences 2>&1' '';
        };
        environmentFiles = [ "/etc/gluetun.env" ];
        volumes = [ "/var/lib/gluetun:/gluetun" ];
        ports = [ "8080:8080" ]; # qbittorrent web ui
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun"
        ];
      };

      # Shares gluetun's network namespace, so torrent traffic can only leave through the VPN.
      qbittorrent = linuxserver "qbittorrent" // {
        dependsOn = [ "gluetun" ];
        extraOptions = [ "--network=container:gluetun" ];
      };
    };

  systemd.services = lib.genAttrs (map (name: "docker-${name}") mediaContainers) (_: {
    unitConfig.RequiresMountsFor = [ mediaDir ];
  });
}
