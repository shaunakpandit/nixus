{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;

    settings = {
      font-thicken = true;

      mouse-hide-while-typing = true;
      macos-titlebar-style = "hidden";

      window-padding-x = 12;
      window-padding-y = "12,4";
    };
  };

  stylix.targets.ghostty = {
    enable = true;
    fonts.enable = true;
    colors = {
      enable = true;
      override = {
        # hacker https://brand.hackernoon.com/visual-assets/color-palettes
        # green:
        # cursor-color = "#00ED8A";
        # cursor-text = "#000000";
        # pink:
        cursor-color = "#F274B1";
        cursor-text = "#000000";
      };
    };
  };
}
