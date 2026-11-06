{ config, pkgs, ... }:

{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/stylix.nix
    ../../system/optimization.nix
    ../../system/audio.nix
    ../../system/boot.nix
    ../../system/locale.nix
    ../../system/utils.nix
    ../../system/fail2ban.nix
    ../../system/tailscale.nix
    ../../system/nvidiaLegacy.nix
    ../../system/virtualisation.nix
    # ../../containers/portainer.nix
    ../../containers/openwebui.nix
    ../../containers/plex.nix
    ../../containers/grimmory.nix
    ../../containers/craftycontroller.nix
    ../../containers/monitoring.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "thoth";
  networking.networkmanager.enable = true;

  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Lets t14 use thoth as a remote builder (see nix.buildMachines in hosts/t14/configuration.nix).
  nix.settings.trusted-users = [
    "root"
    "hugh"
  ];

  users.users.hugh = {
    # root@t14's build key. Create it on t14 with:
    #   sudo ssh-keygen -t ed25519 -f /root/.ssh/nixbuild -N "" -C root@t14
    # and paste the output of `sudo cat /root/.ssh/nixbuild.pub` here.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAOMhTiyoWYdjPSyRo/X64KEys4YMMwiGDs5NnC/vPp root@t14"
    ];
    isNormalUser = true;
    description = "hugh";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    ];
  };

  programs.zsh.enable = true;
  # for zsh autocompletions
  # see: https://home-manager-options.extranix.com/?query=programs&release=master
  environment.pathsToLink = [ "/share/zsh" ];

  # for sshing with x256 color terminals
  environment.enableAllTerminfo = true;

  environment.systemPackages = with pkgs; [
    fd
    bc
    gcc
    git-ignore
    xdg-utils
    curl
    go
    comma
    lua
    luarocks
    cargo
    bat
    fzf
    ripgrep
    unzip
    dig
    wev
    tree-sitter
    mysql84
    docker-compose
    compose2nix
  ];

  # fonts.packages = with pkgs; [
  #   nerd-fonts.lilex
  # ];

  # Open ports in the firewall.
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
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
