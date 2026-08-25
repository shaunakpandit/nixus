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

  # Dark Techbase theme.
  techbase = {
    # Backgrounds and foregrounds
    base00 = "191d23"; # normal background
    base01 = "1b1f25"; # panel background
    base02 = "1f242d"; # selection background
    base03 = "474b65"; # comments
    base04 = "7e8193"; # secondary foreground / quotes
    base05 = "ccd5e5"; # normal foreground
    base06 = "d6ddea"; # float foreground
    base07 = "d6ddea"; # brightest foreground

    # Accent colors
    base08 = "f71735"; # red / errors
    base09 = "b85b53"; # numbers
    base0A = "e9b872"; # yellow / search
    base0B = "74baa8"; # green / strings
    base0C = "1a8c9b"; # cyan / info
    base0D = "a9b9ef"; # blue / keywords
    base0E = "bcb6ec"; # magenta / constants
    base0F = "b09884"; # operators
  };

  # Light Techbase theme.
  techbaseLite = {
    # Backgrounds and foregrounds
    base00 = "d4d4d4"; # normal background
    base01 = "c6c6c6"; # embedded background
    base02 = "a5c6f2"; # visual selection
    base03 = "5f6078"; # comments
    base04 = "55576e"; # secondary foreground / quotes
    base05 = "202020"; # normal foreground
    base06 = "282828"; # float foreground
    base07 = "202020"; # strongest foreground

    # Accent colors
    base08 = "d00000"; # red / errors
    base09 = "b00000"; # numbers
    base0A = "deb51d"; # yellow / search
    base0B = "45763c"; # green / strings
    base0C = "00a516"; # raw strings
    base0D = "0048a0"; # blue / info
    base0E = "0048c8"; # keywords / constants
    base0F = "c7a31a"; # operators
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

    # black-metal-imortal
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-immortal.yaml";
    base16Scheme = techbaseLite;
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
