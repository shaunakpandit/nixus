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

  # Add go binaries to PATH
  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.local/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    shellAliases = {
      rb = "sudo nixos-rebuild switch --flake ~/dev/nixos#t14";
      nc = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system ; sudo nix-collect-garbage --delete-old ; nix-collect-garbage --delete-old";
      nixos = "cd ~/dev/nixos";
      vi = "nvim";
      vim = "nvim";
      tm = "tmux new -A -s code -n code \; neww -d -S -t code: -n term";
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
