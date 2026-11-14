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
    ../../system/zfs.nix
    ../../system/samba.nix
    ../../containers/unbound.nix
    ../../containers/pihole.nix
    ../../containers/glance-remote.nix
    ../../containers/plex.nix
    ../../containers/arr.nix
  ];

  # LTS, because zfs often lags the newest kernel and gets marked broken.
  boot.kernelPackages = pkgs.linuxPackages;

  # Required by zfs; any stable unique value.
  networking.hostId = "7a3d91c2";

  # Pool "tank" on the 6TB disk, created with mountpoint=legacy so systemd orders services after it.
  fileSystems."/mnt/media" = {
    device = "tank";
    fsType = "zfs";
    # Boot even if the pool is missing.
    options = [ "nofail" ];
  };

  networking.hostName = "rama";
  networking.networkmanager.enable = true;

  # DHCP hands out rama itself, so without a fallback docker can't resolve the
  # registry to pull pihole while pihole is down. Port 53 refuses when pihole
  # is stopped, so glibc moves straight on to 1.1.1.1.
  networking.networkmanager.insertNameservers = [
    "127.0.0.1"
    "1.1.1.1"
  ];

  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.icarus = {
    isNormalUser = true;
    description = "icarus";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
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
      32400 # plex
      8080 # qbittorrent
      9696 # prowlarr
      8989 # sonarr
      7878 # radarr
      8686 # lidarr
      5299 # lazylibrarian
      6767 # bazarr
    ];
    allowedUDPPorts = [
      53 # pihole
      5335 # unbound
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
