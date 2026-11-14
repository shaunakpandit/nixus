{ config, ... }:
let
  enabled = {
    enable = true;
    openFirewall = true;
  };
in
{
  nixarr = {
    enable = true;
    mediaUsers = [ config.var.username ];

    # Proton WireGuard config, kept outside the repo. One-time setup:
    #   sudo install -d -m 700 /data/.secret
    #   sudo install -m 600 <proton-pt.conf> /data/.secret/wg.conf
    # Verify the namespace exits through Proton: sudo ip netns exec wg curl -s ifconfig.me
    vpn = {
      enable = true;
      wgConf = "/data/.secret/wg.conf";
    };

    # Only the torrent client goes through the VPN; the arrs get rate-limited by indexers behind it.
    qbittorrent = {
      enable = true;
      vpn.enable = true;
    };

    plex = enabled;
    prowlarr = enabled;
    sonarr = enabled;
    radarr = enabled;
    lidarr = enabled;
    bazarr = enabled;
    seerr = enabled;
  };
}
