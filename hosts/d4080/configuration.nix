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
    ../../system/boot.nix
    ../../system/locale.nix
    ../../system/nvidia.nix
    ../../system/mango.nix
    ../../system/gaming/starcitizen.nix
    ../../system/gaming
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # see https://github.com/LovingMelody/nix-citizen/tree/main/pkgs/rsi-launcher
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
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
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      thunar
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
