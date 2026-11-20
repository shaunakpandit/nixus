{ config, inputs, ... }:
let
  enabled = {
    enable = true;
    openFirewall = true;
  };

  # qBittorrent's own WebUI inside the VPN namespace; nixarr whitelists the bridge subnet, so no password.
  qbittorrent = category: {
    name = "qBittorrent";
    implementation = "QBittorrent";
    fields = {
      host = "192.168.15.1";
      port = config.nixarr.qbittorrent.qui.internalPort;
    }
    // category;
  };

  # settings-sync talks to the arr APIs over localhost.
  localAuth.settings.auth.required = "DisabledForLocalAddresses";
in
{
  imports = [ inputs.nixarr.nixosModules.default ];

  services.prowlarr = localAuth;
  services.sonarr = localAuth;
  services.radarr = localAuth;
  services.lidarr = localAuth;

  nixarr = {
    enable = true;
    mediaUsers = [ config.var.username ];

    # Proton WireGuard config, kept outside the repo. One-time setup:
    #   sudo install -d -m 700 /data/.secret
    #   sudo install -m 600 <proton-pt.conf> /data/.secret/wg.conf
    #   sudo systemctl restart wg.service
    # Verify the namespace exits through Proton: sudo ip netns exec wg curl -s ifconfig.me
    vpn = {
      enable = true;
      wgConf = "/data/.secret/wg.conf";
    };

    # Only the torrent client goes through the VPN; the arrs get rate-limited by indexers behind it.
    # The qui WebUI on :5252 asks for an account on first visit.
    qbittorrent = enabled // {
      vpn.enable = true;
    };

    # Tailnet only: tailscale.nix opens 32400 on tailscale0. Keep Plex "Remote Access" off in its settings.
    plex.enable = true;

    # Public trackers only. List available names: sudo nixarr show-prowlarr-schemas indexer | jq '.[].sort_name'
    prowlarr = enabled // {
      settings-sync = {
        enable-nixarr-apps = true;
        indexers = map (sort_name: { inherit sort_name; }) [
          "pirate bay"
          "yts"
          "nyaa si"
          "limetorrents"
        ];
      };
    };

    sonarr = enabled // {
      settings-sync.downloadClients = [ (qbittorrent { tvCategory = "sonarr"; }) ];
    };
    radarr = enabled // {
      settings-sync.downloadClients = [ (qbittorrent { movieCategory = "radarr"; }) ];
    };

    # Lidarr has no settings-sync. One-time, in the UI (:8686):
    #   Settings > Download Clients > + qBittorrent: host 192.168.15.1, port 8085, category lidarr
    #   Settings > Media Management > Root Folders > + /data/media/library/music, Quality Profile "Lossless" (FLAC minimum)
    lidarr = enabled;

    bazarr = enabled // {
      settings-sync = {
        sonarr.enable = true;
        radarr.enable = true;
      };
    };

    # Pick each profile as the default in Seerr's Sonarr/Radarr server settings.
    seerr = enabled;

    # TRaSH guide profiles. Sonarr: 2160p preferred, 1080p fallback. Radarr: 2160p only.
    recyclarr = {
      enable = true;
      configuration = {
        sonarr.series = {
          base_url = "http://localhost:8989";
          api_key = "!env_var SONARR_API_KEY";
          quality_definition.type = "series";
          quality_profiles = [
            {
              trash_id = "c4cadd6b35b95f62c3d47a408e53e2f7"; # WEB-2160p (Combined)
              reset_unmatched_scores.enabled = true;
            }
          ];
        };
        radarr.movies = {
          base_url = "http://localhost:7878";
          api_key = "!env_var RADARR_API_KEY";
          quality_definition.type = "movie";
          quality_profiles = [
            {
              trash_id = "64fb5f9858489bdac2af690e27c8f42f"; # UHD Bluray + WEB
              reset_unmatched_scores.enabled = true;
            }
          ];
        };
      };
    };
  };
}
