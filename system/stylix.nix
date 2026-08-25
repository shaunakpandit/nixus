{
  pkgs,
  ...
}:
let
  lilex = {
    package = pkgs.nerd-fonts.lilex;
    name = "Lilex Nerd Font";
  };
  zed = {
    package = pkgs.nerd-fonts.zed-mono;
    name = "ZedMono Nerd Font";
  };
  iosevka = {
    package = pkgs.nerd-fonts.iosevka;
    name = "Iosevka Nerd Font";
  };
  space = {
    package = pkgs.nerd-fonts.space-mono;
    name = "SpaceMono Nerd Font";
  };
in
{
  # docs: https://nix-community.github.io/stylix/
  stylix = {
    enable = true;
    # https://github.com/tinted-theming/schemes
    # base0B is the highlight I love. see mango config for manually setting color
    # base05 white
    # linke: https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/black-metal-immortal.yaml
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-immortal.yaml";
    image = ../walls/solar.png;
    fonts = {
      serif = zed;

      sansSerif = zed;

      monospace = zed;

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    targets = {
      chromium.enable = true;
    };
  };
}
