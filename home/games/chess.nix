{
  config,
  pkgs,
  ...
}:
{
  # Chess
  home.packages = with pkgs; [
    chess-tui
    stockfish
  ];

  xdg.configFile."chess-tui/config.toml".text = ''
    # Put your existing chess-tui configuration here.

    engine_path = "${pkgs.stockfish}/bin/stockfish"
  '';
}
