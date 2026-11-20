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

  networking.firewall = {
    allowedTCPPorts = [
      8000 # portainer
      9443 # portainer

      3000 # webui

      32400 # plex

      6060 # grimmory

      8443 # Crafty Controller; web page
      8123 # Crafty Controller; Optional map web server, e.g. Dynmap

      8080 # glance
      8081 # gatus

      4200 # pattern game
    ];

    allowedTCPPortRanges = [
      {
        # for crafy controller
        from = 25500;
        to = 25600;
      }
    ];
    # Optional: local network discovery for plex
    allowedUDPPorts = [
      32410 # plex
      32412 # plex
      32413 # plex
      32414 # plex

      19132 # Craftcontroller; Bedrock
    ];
  };

  system.stateVersion = "26.05"; # Release of the first install; never change it.
}
