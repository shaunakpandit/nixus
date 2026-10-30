{
  config,
  pkgs,
  lib,
  ...
}:
let
  c = config.lib.stylix.colors;
  rgb = base: {
    Rgb = map (channel: lib.toInt c."${base}-rgb-${channel}") [
      "r"
      "g"
      "b"
    ];
  };
  # chess-tui's built-in skins, copied from the skins.json it generates on first run.
  defaultSkins = lib.importJSON ../../dots/chess-tui/skins.json;
in
{
  # Chess
  home.packages = with pkgs; [
    chess-tui
    stockfish
  ];

  xdg.configFile."chess-tui/config.toml".text = ''
    # Put your existing chess-tui configuration here.

    engine_path = "${pkgs.stockfish}/bin/stockfish"
    selected_skin_name = "Stylix"
  '';

  xdg.configFile."chess-tui/skins.json".text = builtins.toJSON (
    defaultSkins
    // {
      skins = defaultSkins.skins ++ [
        {
          name = "Stylix";
          piece_style = "DEFAULT";
          board_white_color = rgb "base0B";
          board_black_color = rgb "base0A";
          piece_white_color = rgb "base07";
          piece_black_color = rgb "base00";
          cursor_color = rgb "base08";
          selection_color = rgb "base09";
          last_move_color = rgb "base0E";
        }
      ];
    }
  );
}
