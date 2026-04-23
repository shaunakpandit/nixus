{ pkgs, config }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-immortal.yaml";
  };
}
