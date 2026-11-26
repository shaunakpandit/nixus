{
  imports = [
    ./variables.nix
    ../../home/profiles/desktop.nix
    ../../home/protondrive.nix
    ../../home/nightlight.nix
    ../../home/tradingview.nix
    ../../home/games/chess.nix
    ../../home/vnc.nix
    ../../home/dunst.nix
  ];

  mytools.gowifi.enable = true;
  mytools.gostartools.enable = true;

  home.stateVersion = "25.11";
}
