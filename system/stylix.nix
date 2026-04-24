{
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-immortal.yaml";
    image = ../walls/solar.png;
  };
}
