# Every NixOS host. The host sets var.username and var.hostname in its variables.nix.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    ../stylix.nix
    ../optimization.nix
    ../boot.nix
    ../locale.nix
    ../utils.nix
  ];

  var.homelab = import ../../homelab.nix;

  networking.hostName = config.var.hostname;
  networking.networkmanager.enable = true;

  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.${config.var.username} = {
    isNormalUser = true;
    description = config.var.username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
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
    # xdg-open, which lazygit uses to open PRs in a browser
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
    tree-sitter
    mysql84
  ];
}
