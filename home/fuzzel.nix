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
        icons-enabled = true;
        anchor = "bottom";
        lines = 10;
        horizontal-pad = 12;
        vertical-pad = 4;
        width = 50;
        prompt = "\"run: \"";
      };
      border = {
        width = 0;
        radius = 0;
      };
      key-bindings = {
        delete-line-forward = "Control+Shift+u";
        next-with-wrap = "Control+j";
        prev-with-wrap = "Control+k";
      };
    };
  };
}
