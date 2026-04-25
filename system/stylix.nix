{
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    # https://github.com/tinted-theming/schemes
    # base0B is the highlight I love. see mango config for manually setting color
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-immortal.yaml";
    image = ../walls/solar.png;
  };
}
