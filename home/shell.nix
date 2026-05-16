{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
    jq
  ];

  xdg.configFile."tmux" = {
    source = ../dots/tmux;
    recursive = true;
  };

  xdg.configFile."ghostty" = {
    source = ../dots/ghostty;
    recursive = true;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "small";
        source = "nixos";
      };
      modules = [
        "os"
        "kernel"
        "bios"
        "break"
        "host"
        "cpu"
        "gpu"
        "chasis"
        "break"
        "cpuusage"
        "memory"
        "physicaldisk"
        "physicalmemory"
        "break"
        "packages"
        "processes"
        "uptime"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    sessionVariables = {
      MUSIC_LEAGUE_DB_URL = "mysql://mluser:mlpassword@192.168.4.28:33061/musicleague";
    };
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    initExtra = ''
      fastfetch
    '';
    shellAliases = {
      rbt = "sudo nixos-rebuild switch --flake ~/dev/nixus#t14";
      rbd = "sudo nixos-rebuild switch --flake ~/dev/nixus#d4080";
      nc = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system ; sudo nix-collect-garbage --delete-old ; nix-collect-garbage --delete-old";
      nixos = "cd ~/dev/nixos";
      vi = "nvim";
      vim = "nvim";
      tm = "tmux new -A -s code -n code ';' neww -d -S -t code: -n term";
      c = "clear";
      ".." = "cd ..";
      zs = "source ~/.zshrc";
      jk = "exit";
      ms = "mango";
      faf = "fastfetch";
    };
  };

  programs.yazi = {
    enable = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
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
