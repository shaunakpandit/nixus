{ pkgs, ... }:
{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/profiles/server.nix
    ../../system/nvidiaLegacy.nix
    ../../system/zfs.nix
    ../../system/nixarr.nix
    ../../system/nas.nix
    ../../containers/unbound.nix
    ../../containers/pihole.nix
    ../../containers/glance-remote.nix
  ];

  # Default LTS kernel, because linuxPackages_latest often outruns ZFS support.

  # Required by ZFS; random, must stay stable.
  networking.hostId = "279ca6f9";

  # DHCP hands out rama itself, so without a fallback docker can't resolve the
  # registry to pull pihole while pihole is down. Port 53 refuses when pihole
  # is stopped, so glibc moves straight on to 1.1.1.1.
  networking.networkmanager.insertNameservers = [
    "127.0.0.1"
    "1.1.1.1"
  ];

  # After thoth's 03:00 run, so thoth's pulls don't land while pihole is restarting.
  systemd.services.update-containers.startAt = "Tue *-*-* 03:15:00";

  # Global ports, so these are also open on tailscale0 for tailnet DNS.
  networking.firewall = {
    allowedTCPPorts = [
      53 # pihole
      8089 # pihole web ui
      5335 # unbound
      27973 # glance agent
      2375 # docker socket proxy, read only, for glance
    ];
    allowedUDPPorts = [
      53 # pihole
      5335 # unbound
    ];
  };

  system.stateVersion = "26.05"; # Release of the first install; never change it.
}
