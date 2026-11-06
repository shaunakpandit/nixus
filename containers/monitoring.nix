{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.var.homelab)
    thoth
    rama
    pihole
    piholePort
    traefik
    ;
  yaml = pkgs.formats.yaml { };
  piholeWeb = "http://${pihole}:${toString piholePort}";

  # Shared by gatus (status checks) and glance (dashboard links).
  thothServices = [
    {
      name = "Open WebUI";
      url = "http://${thoth}:3000";
    }
    {
      name = "Plex";
      url = "http://${thoth}:32400/web";
      check = "http://${thoth}:32400/identity";
    }
    {
      name = "Grimmory";
      url = "http://${thoth}:6060";
    }
    {
      name = "Crafty Controller";
      url = "https://${thoth}:8443";
      insecure = true; # self-signed cert
    }
    {
      name = "Gatus";
      url = "http://${thoth}:8081";
    }
  ];

  dnsCheck = {
    query-name = "example.com";
    query-type = "A";
  };
  connected = [ "[CONNECTED] == true" ];
  ok = [ "[STATUS] == 200" ];

  gatusConfig = yaml.generate "gatus.yaml" {
    storage = {
      type = "sqlite";
      path = "/data/data.db";
    };
    endpoints =
      map (service: {
        inherit (service) name;
        group = "thoth";
        url = service.check or service.url;
        client.insecure = service.insecure or false;
        conditions = ok;
      }) thothServices
      ++ [
        {
          name = "SSH";
          group = "thoth";
          url = "tcp://${thoth}:22";
          conditions = connected;
        }
        {
          name = "Pi-hole web";
          group = "dns";
          url = "${piholeWeb}/admin/";
          conditions = ok;
        }
        {
          name = "Pi-hole DNS";
          group = "dns";
          url = pihole;
          dns = dnsCheck;
          conditions = [ "[DNS_RCODE] == NOERROR" ];
        }
        {
          # Requires unbound to listen on the LAN, not just 127.0.0.1.
          name = "Unbound";
          group = "dns";
          url = "${pihole}:5335";
          dns = dnsCheck;
          conditions = [ "[DNS_RCODE] == NOERROR" ];
        }
        {
          name = "Traefik";
          group = "traefik";
          url = "tcp://${traefik}:443";
          conditions = connected;
        }
      ]
      ++
        map
          (domain: {
            name = domain;
            group = "traefik";
            url = "https://${domain}";
            conditions = ok ++ [ "[CERTIFICATE_EXPIRATION] > 168h" ];
          })
          [
            "webui.jssp.io"
            "booklore.jssp.io"
          ];
  };

  # Glance takes colors as "H S L".
  hsl =
    hex:
    let
      channel = offset: lib.fromHexString (builtins.substring offset 2 hex) / 255.0;
      red = channel 0;
      green = channel 2;
      blue = channel 4;
      max = lib.max red (lib.max green blue);
      min = lib.min red (lib.min green blue);
      delta = max - min;
      lightness = (max + min) / 2;
      saturation =
        if delta == 0 then 0 else delta / (if lightness > 0.5 then 2 - max - min else max + min);
      sector =
        if delta == 0 then
          0
        else if max == red then
          (green - blue) / delta
        else if max == green then
          (blue - red) / delta + 2
        else
          (red - green) / delta + 4;
      hue = 60 * (if sector < 0 then sector + 6 else sector);
      round = number: toString (builtins.floor (number + 0.5));
    in
    "${round hue} ${round (saturation * 100)} ${round (lightness * 100)}";

  colors = config.lib.stylix.colors;

  # Links only; the services on rama and the pis aren't checked by gatus.
  linkedServices = thothServices ++ [
    {
      name = "Pi-hole (rama)";
      url = "http://${rama}:8089/admin/";
    }
    {
      name = "Pi-hole (pi)";
      url = "${piholeWeb}/admin/";
    }
    {
      name = "Traefik";
      url = "http://${traefik}:8080/dashboard/";
    }
  ];

  glanceConfig = yaml.generate "glance.yml" {
    theme = {
      background-color = hsl colors.base00;
      primary-color = hsl colors.base0B;
      positive-color = hsl colors.base0B;
      negative-color = hsl colors.base08;
    };
    pages = [
      {
        name = "Home";
        columns = [
          {
            size = "small";
            widgets = [
              { type = "calendar"; }
              {
                type = "server-stats";
                servers = [
                  {
                    type = "local";
                    name = "thoth";
                    hide-mountpoints-by-default = true;
                    mountpoints."/".name = "root";
                  }
                  {
                    type = "remote";
                    name = "rama";
                    url = "http://${rama}:27973";
                  }
                ];
              }
              {
                type = "dns-stats";
                title = "Pi-hole (rama)";
                service = "pihole-v6";
                url = "http://${rama}:8089";
              }
            ];
          }
          {
            size = "full";
            widgets = [
              {
                type = "monitor";
                title = "Services";
                cache = "1m";
                sites = map (service: {
                  title = service.name;
                  inherit (service) url;
                  check-url = service.check or service.url;
                  allow-insecure = service.insecure or false;
                }) linkedServices;
              }
              {
                type = "docker-containers";
                title = "thoth containers";
              }
              {
                # Served by containers/glance-remote.nix.
                type = "docker-containers";
                title = "rama containers";
                sock-path = "tcp://${rama}:2375";
              }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "rss";
                title = "Hacker News";
                limit = 15;
                feeds = [ { url = "https://news.ycombinator.com/rss"; } ];
              }
              {
                type = "rss";
                title = "Mindscape";
                limit = 10;
                feeds = [ { url = "https://rss.libsyn.com/shows/604590/destinations/5264190.xml"; } ];
              }
            ];
          }
        ];
      }
    ];
  };
in
{
  systemd.tmpfiles.rules = [ "d /var/lib/gatus 0750 root root -" ];

  virtualisation.oci-containers.containers = {
    gatus = {
      image = "twinproduction/gatus:latest";
      pull = "always";
      environment.TZ = config.time.timeZone;
      ports = [ "8081:8080" ];
      volumes = [
        "${gatusConfig}:/config/config.yaml:ro"
        "/var/lib/gatus:/data"
      ];
    };

    glance = {
      image = "glanceapp/glance:latest";
      pull = "always";
      environment.TZ = config.time.timeZone;
      ports = [ "8080:8080" ];
      volumes = [
        "${glanceConfig}:/app/config/glance.yml:ro"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      extraOptions = [ "--hostname=thoth" ];
    };
  };
}
