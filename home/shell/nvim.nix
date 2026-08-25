{ config, pkgs, ... }:
{
  xdg.configFile."nvim" = {
    source = builtins.filterSource (
      path: type: baseNameOf path != "nvim-pack-lock.json"
    ) ../../dots/nvim;
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
    nodejs
    nil
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraPackages = with pkgs; [
      # TypeScript / JavaScript / PHP
      vtsls
      dprint
      intelephense
      phpstan
      vscode-langservers-extracted # Provides css-languageserver

      # Go
      gopls
      gofumpt
      gotools # Provides goimports
      golines
      gomodifytags
      gotests

      # Lua
      lua-language-server
      stylua

      # General
      bash-language-server
      rust-analyzer
      helm-ls
      superhtml

      # Nix
      nil
      nixfmt-rs
      nixpkgs-fmt
    ];
  };

  stylix.targets.neovim = {
    enable = true;
    colors.enable = true;
  };
}
