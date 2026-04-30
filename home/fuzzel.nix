{
  config,
  pkgs,
  inputs,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        icons-enabled = false;
        anchor = "top";
        lines = 7;
        horiozontal-pad = 12;
        vertical-pad = 4;
      };
      border = {
        radius = 0;
      };
      key-bindings = {
        next-with-wrap = "Control+j";
        prev-with-wrap = "Control+k";
      };
    };
  };
}
