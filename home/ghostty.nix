{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Map ANSI cyan to the active Stylix base0B color.
  cyan = config.lib.stylix.colors.withHashtag.base0B;
in
{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;

    settings = {
      font-thicken = true;

      mouse-hide-while-typing = true;
      macos-titlebar-style = "hidden";

      window-padding-x = 12;
      window-padding-y = 4; # top,bottom
      window-padding-balance = true;
      # ensures that app within ghostty owns background color
      window-padding-color = "extend";
      # window-step-resize = true;

      # ANSI normal cyan and bright cyan.
      palette = lib.mkForce [
        # THEME_UPDATE
        # cyan override only needed for blackmetal immortal update
        "6=${cyan}"
        # "14=${cyan}"
      ];
      # hacker https://brand.hackernoon.com/visual-assets/color-palettes
      # green:
      # cursor-color = lib.mkForce "#00ED8A";
      # cursor-text = lib.mkForce "#000000";
      # pink:
      cursor-color = lib.mkForce "#F274B1";
      cursor-text = lib.mkForce "#000000";
    };
  };

  stylix.targets.ghostty = {
    enable = true;
    fonts.enable = true;
    colors = {
      enable = true;
    };
  };
}
