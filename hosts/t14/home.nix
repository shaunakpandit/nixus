{
  imports = [
    ./variables.nix
    ../../home/profiles/desktop.nix
    ../../home/nightlight.nix
    ../../home/tradingview.nix
    ../../home/games/chess.nix
  ];

  mytools.gowifi.enable = true;
  mytools.gostartools.enable = true;

  home.stateVersion = "25.11";
}
