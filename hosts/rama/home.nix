{
  imports = [
    ./variables.nix
    ../../home/profiles/base.nix
    ../../home/shell/claudeUnbound.nix
  ];

  home.stateVersion = "26.05";
}
