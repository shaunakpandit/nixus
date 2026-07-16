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
      source <(fzf --zsh)
      fastfetch
    '';
    shellAliases = {
      rb = "${config.var.rebuildCommand}";
      nc = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system ; sudo nix-collect-garbage --delete-old ; nix-collect-garbage --delete-old";
      nixos = "cd ~/dev/nixus";
      vi = "nvim";
      vim = "nvim";
      tm = "tmux new -A -s code -n code ';' neww -d -S -t code: -n term";
      c = "clear";
      ".." = "cd ..";
      zs = "source ~/.zshrc";
      jk = "exit";
      ms = "mango";
      faf = "fastfetch";
      ff = "ls -R | fuzzel -d | xargs -r nvim";
      fc = "cliphist list | fuzzel -d | cliphist decode | wl-copy";
      fg = "fuzzel -d --lines=0 --prompt=\"google: \" | xargs -I {} xdg-open \"https://google.com/search?q={}\"";
      fh = "fuzzel -d --lines=0 --prompt=\"nix-options: \" | xargs -I {} xdg-open \"https://home-manager-options.extranix.com/?query={}&release=master\"";
      fo = "fuzzel -d --lines=0 --prompt=\"homemanager-options: \" | xargs -I {} xdg-open \"https://search.nixos.org/options?channel=unstable&query={}\"";
      gl = "git pull";
      bios = "systemctl reboot --firmware-setup";
      singapl = "ssh singapl@192.168.4.28";
      cplex = "rsync -avh --progress \ singapl@192.168.4.28:/mnt/library/music/ \ ~/Music";
      cdone = "cp -r ~/Music/NewDownloads/ ~/Music/";
      tplex = "rsync -avh --progress \ ~/Music/NewDownloads \ singapl@192.168.4.28:/mnt/library/music/ ";
      mzip = "for f in *.zip; do unzip '$f' -d ~/Music/NewDownloads; done";
    };
  };

  programs.fzf = {
    enable = true;
  };

  programs.bat = {
    enable = true;
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

  programs.bottom = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "shaunakpandit";
    userEmail = "shaunakdpandit@gmail.com";
    settings = {
      pull = {
        rebase = false;
      };
    };
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
