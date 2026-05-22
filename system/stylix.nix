{
  pkgs,
  ...
}:
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
      serif = {
        package = pkgs.nerd-fonts.lilex;
        name = "Lilex Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.lilex;
        name = "Lilex Nerd Font";
      };

      monospace = {
        package = pkgs.nerd-fonts.lilex;
        name = "Lilex Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phingers-cursors-dark";
      size = 42;
    };
  };
}
