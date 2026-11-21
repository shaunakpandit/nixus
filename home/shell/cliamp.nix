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

  # force: cliamp rewrites these when you (un)favorite in the UI, replacing the store
  # symlink with a regular file; the rebuild then resets them to this list.
  xdg.configFile."cliamp/radio_favorites.toml" = {
    force = true;
    source = (pkgs.formats.toml { }).generate "radio_favorites.toml" {
      station = [
        {
          name = "WGUC Cincinnati Classical Music Radio";
          url = "https://stream.cinradio.org/wguc";
          homepage = "https://www.wguc.org/";
        }
        {
          name = "Radio Caprice - Classical Piano";
          url = "http://79.120.39.202:9069/;";
          tags = "classical,piano";
          homepage = "http://radcap.ru/classicalpiano.html";
        }
        {
          name = "Deephouse radio";
          url = "http://ec1.everestcast.host:1490/stream?xi1amefeqvksbquhue3jidp6boikushz";
          tags = "deephouse";
          homepage = "http://dhr.com/";
        }
      ];
    };
  };

  xdg.configFile."cliamp/podcast_subscriptions.json" = {
    force = true;
    text = builtins.toJSON [
      {
        id = "1406534739";
        title = "Sean Carroll's Mindscape: Science, Society, Philosophy, Culture, Arts, and Ideas";
        feed_url = "https://rss.libsyn.com/shows/604590/destinations/5264190.xml";
        author = "Sean Carroll";
      }
    ];
  };

  programs.cava = {
    enable = true;
  };
}
