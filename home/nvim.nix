{ config, pkgs, ... }:
{
  xdg.configFile."nvim" = {
    source = builtins.filterSource (path: type: baseNameOf path != "nvim-pack-lock.json") ../dots/nvim;
    recursive = true;
  };

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    comment = "Edit text files";
    exec = "ghostty -e nvim %F";
    icon = "nvim";
    terminal = false;
    categories = [
      "Utility"
      "TextEditor"
    ];
    mimeType = [
      "text/plain"
      "text/x-python"
      "text/x-tex"
    ];
  };

  home.packages = with pkgs; [
    lua-language-server
    nodejs
    nil
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
