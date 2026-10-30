{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  home.packages = with pkgs; [
    cliamp
  ];

  xdg.configFile."cliamp" = {
    source = ../../dots/cliamp;
    recursive = true;
  };

  # Capitalized filename so it matches `theme = "Stylix"` whether cliamp title-cases names or not.
  xdg.configFile."cliamp/themes/Stylix.toml".text = ''
    bg = "${c.base00}"
    accent = "${c.base0B}"
    bright_fg = "${c.base05}"
    fg = "${c.base04}"
    green = "${c.base0B}"
    yellow = "${c.base0A}"
    red = "${c.base08}"
  '';

  programs.cava = {
    enable = true;
  };
}
