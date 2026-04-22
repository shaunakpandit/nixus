{ config, pkgs, ... }:
{
  xdg.configFile."tmux" = {
    source = ../dots/tmux;
    recursive = true;
  };

  xdg.configFile."ghostty" = {
    source = ../dots/ghostty;
    recursive = true;
  };

  home.packages = with pkgs; [
    fastfetch
    ripgrep
    rustup
    fd
    fzf
  ];

  programs.btop = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "shaunakpandit";
    userEmail = "shaunakdpandit@gmail.com";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  programs.tmux = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    shellAliases = {
      rb = "sudo nixos-rebuild switch --flake ~/dev/nixos#t14";
      nixos = "cd ~/dev/nixos";
      vi = "nvim";
      vim = "nvim";
      c = "clear";
      ".." = "cd ..";
      zs = "source ~/.zshrc";
      jk = "exit";
    };
  };
  programs.gh = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
  };

}
