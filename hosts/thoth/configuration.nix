{ config, pkgs, ... }:
{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/profiles/server.nix
    ../../system/nvidiaLegacy.nix
    ../../system/mtp.nix
    ../../system/claudebox.nix
    # ../../containers/portainer.nix
    ../../containers/openwebui.nix
    ../../containers/plex.nix
    ../../containers/grimmory.nix
    ../../containers/craftycontroller.nix
    ../../containers/monitoring.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Lets t14 use thoth as a remote builder (see nix.buildMachines in hosts/t14/configuration.nix).
  nix.settings.trusted-users = [
    "root"
    "hugh"
  ];

  users.users.${config.var.username}.openssh.authorizedKeys.keys = [
    # Public half of t14's nixbuild_ssh_key (secrets/t14.yaml)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAOMhTiyoWYdjPSyRo/X64KEys4YMMwiGDs5NnC/vPp root@t14"
    # void@t14
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOST1BDY81RViIwoRqex1mYipRpRdDf3fwBgUAYmusVS shaunakdpandit@gmail.com"
  ];

  # Docker-published container ports bypass this firewall, and containers/ open their own
  # host-network ports. See everything exposed with `nix eval --raw .#ports.thoth`.
  networking.firewall.allowedTCPPorts = [
    8000 # portainer
    9443 # portainer
    4200 # pattern game
  ];

  system.stateVersion = "26.05"; # Release of the first install; never change it.
}
