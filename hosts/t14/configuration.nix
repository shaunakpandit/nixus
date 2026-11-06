# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/stylix.nix
    ../../system/optimization.nix
    ../../system/audio.nix
    ../../system/boot.nix
    ../../system/locale.nix
    ../../system/utils.nix
    ../../system/laptop.nix
    ../../system/mango.nix
    ../../system/gaming
  ];

  nix.settings.substituters = [ "https://cache.lantian.pub/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];

  # TODO: set as 'pkgs.linuxPackages_latest;' on first build
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # Offload builds to thoth; falls back to building locally when thoth is unreachable.
  # test with sudo nix store info --store ssh-ng://hugh@192.168.4.28
  nix.distributedBuilds = true;
  # thoth fetches from caches itself instead of pulling everything through the laptop
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = "192.168.4.28";
      sshUser = "hugh";
      # The nix daemon runs as root, so root needs its own key. Create it on t14 with:
      #   sudo ssh-keygen -t ed25519 -f /root/.ssh/nixbuild -N "" -C root@t14
      # Then put the output of `sudo cat /root/.ssh/nixbuild.pub` in
      # users.users.hugh.openssh.authorizedKeys.keys in hosts/thoth/configuration.nix.
      sshKey = "/root/.ssh/nixbuild";
      protocol = "ssh-ng";
      system = "x86_64-linux";
      maxJobs = 8;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
  ];
  # Pins thoth's host key so root's non-interactive ssh doesn't stall on the fingerprint prompt.
  # Get it with `ssh-keyscan -t ed25519 192.168.4.28` (drop the leading IP),
  # or `cat /etc/ssh/ssh_host_ed25519_key.pub` on thoth.
  programs.ssh.knownHosts.thoth = {
    hostNames = [ "192.168.4.28" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJg5rB28CPMtl44xAIjSkdyEuZlh99Iw5+LlM+5O6F/C root@nixos";
  };

  networking.hostName = "t14"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # udev access for qmk keyboards
  hardware.keyboard.qmk.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.void = {
    isNormalUser = true;
    description = "void";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      pkgs.kdePackages.dolphin
      plexamp
      #  thunderbird
    ];
  };

  programs.zsh.enable = true;
  # for zsh autocompletions
  # see: https://home-manager-options.extranix.com/?query=programs&release=master
  environment.pathsToLink = [ "/share/zsh" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    compose2nix
  ];

  # fonts.packages = with pkgs; [
  #   nerd-fonts.lilex
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
