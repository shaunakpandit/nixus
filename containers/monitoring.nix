{ config, pkgs, ... }:

let
  inherit (config.var.homelab)
    thoth
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

  glanceConfig = yaml.generate "glance.yml" {
    pages = [
      {
        name = "thoth";
        columns = [
          {
            size = "small";
            widgets = [
              {
                type = "server-stats";
                servers = [
                  {
                    type = "local";
                    name = "thoth";
                    hide-mountpoints-by-default = true;
                    mountpoints."/".name = "root";
                  }
                ];
              }
              {
                type = "dns-stats";
                service = "pihole-v6";
                url = piholeWeb;
                # Substituted by glance from /etc/glance.env.
                password = "\${PIHOLE_PASSWORD}";
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
                }) thothServices;
              }
              { type = "docker-containers"; }
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
      # Keep the pihole password outside the world-readable Nix store.
      # Create /etc/glance.env containing PIHOLE_PASSWORD=
      environmentFiles = [ "/etc/glance.env" ];
      ports = [ "8080:8080" ];
      volumes = [
        "${glanceConfig}:/app/config/glance.yml:ro"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      extraOptions = [ "--hostname=thoth" ];
    };
  };
}
