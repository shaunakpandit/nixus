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
        anchor = "center";
        lines = 7;
        horizontal-pad = 12;
        vertical-pad = 4;
        prompt = "\"run: \"";
      };
      border = {
        width = 1;
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
