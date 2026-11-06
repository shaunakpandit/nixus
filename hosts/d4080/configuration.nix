{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    ../../system/stylix.nix
    ../../system/optimization.nix
    ../../system/audio.nix
    ../../system/peripherals.nix
    ../../system/boot.nix
    ../../system/locale.nix
    ../../system/utils.nix
    ../../system/fail2ban.nix
    ../../system/nvidia.nix
    ../../system/mango.nix
    ../../system/gaming/starcitizen.nix
    ../../system/gaming/performance.nix
    ../../system/gaming
    ../../system/sops.nix
    ../../system/cliamp.nix
  ];

  # Same as t14: no openssh host key, so the admin key decrypts. /home is on the root fs, so it's readable at boot.
  sops.age.keyFile = "/home/void/.config/sops/age/keys.txt";

  nix.settings.substituters = [ "https://cache.lantian.pub/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];

  boot = {
    # what CachyOS installs on Zen 4: ThinLTO and -march=znver4.
    # The kernel is cached but the nvidia module for it builds locally
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
  };

  networking.hostName = "d4080"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.void = {
    isNormalUser = true;
    description = "void";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      plexamp
      pkgs.kdePackages.dolphin
      #  thunderbird
    ];
  };

  programs.zsh.enable = true;
  # for zsh autocompletions
  # see: https://home-manager-options.extranix.com/?query=programs&release=master
  environment.pathsToLink = [ "/share/zsh" ];

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
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.lilex
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
