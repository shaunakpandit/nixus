{ pkgs, ... }:
{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/profiles/server.nix
    ../../system/nvidiaLegacy.nix
    ../../containers/unbound.nix
    ../../containers/pihole.nix
    ../../containers/glance-remote.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # DHCP hands out rama itself, so without a fallback docker can't resolve the
  # registry to pull pihole while pihole is down. Port 53 refuses when pihole
  # is stopped, so glibc moves straight on to 1.1.1.1.
  networking.networkmanager.insertNameservers = [
    "127.0.0.1"
    "1.1.1.1"
  ];

  # After thoth's 03:00 run, so thoth's pulls don't land while pihole is restarting.
  systemd.services.update-containers.startAt = "Tue *-*-* 03:15:00";

  # No firewall entries: pihole, unbound and the glance agent are Docker-published, which bypasses
  # the firewall on every interface (LAN and tailscale0). See `nix eval --raw .#ports.rama`.

  system.stateVersion = "26.05"; # Release of the first install; never change it.
}
