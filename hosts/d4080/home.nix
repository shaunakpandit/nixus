{
  imports = [
    ./variables.nix
    ../../home/profiles/desktop.nix
    ../../home/protondrive.nix
    ../../home/discord.nix
    ../../home/helium.nix
    ../../home/joystickIdleInhibit.nix
    ../../home/games/prism.nix
  ];

  home.stateVersion = "25.11";
}
