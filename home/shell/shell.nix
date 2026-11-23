{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{
  imports = [ ./tmux.nix ];

  home.packages = with pkgs; [
    jq
  ];

  # xdg.configFile."ghostty" = {
  #   source = ../../dots/ghostty;
  #   recursive = true;
  # };

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
      MUSIC_LEAGUE_DB_URL = "mysql://mluser:mlpassword@${config.var.homelab.thoth}:33061/musicleague";
    };
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    initContent = ''
      source <(fzf --zsh)
    '';
    shellAliases = {
      rb = "${config.var.rebuildCommand}";
      nc = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system ; sudo nix-collect-garbage --delete-old ; nix-collect-garbage --delete-old";
      sc = "sudo nix-store --verify --check-contents --repair";
      nixos = "cd ~/dev/nixus";
      vi = "nvim";
      vim = "nvim";
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
      hugh = "ssh hugh@${config.var.homelab.thoth}";
      rama = "ssh icarus@${config.var.homelab.rama}";
      vnc = "ssh -L 5900:localhost:5900 claudebox";
      vnct = "ssh -L 5900:localhost:5900 claudeboxtail";
      cplex = "rsync -avh --progress singapl@${config.var.homelab.thoth}:/mnt/library/music/ ~/Music";
      cdone = "cp -r ~/Music/NewDownloads/ ~/Music/";
      tplex = "rsync -avh --progress ~/Music/NewDownloads singapl@${config.var.homelab.thoth}:/mnt/library/music/ ";
      mzip = "for f in *.zip; do unzip \"$f\" -d ~/Music/NewDownloads; done";
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
    shellWrapperName = "y";
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
    settings = {
      user = {
        email = lib.mkDefault "shaunakdpandit@gmail.com";
        name = "shaunakpandit";
      };
      pull = {
        rebase = false;
      };
    };
    includes = [
      {
        condition = "gitdir:~/notes/";
        contents.core.hooksPath = ".githooks";
      }
    ];
  };

  programs.ssh = {
    enable = true;
    # The legacy defaults were all OpenSSH's own defaults anyway.
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      # LAN: jump through thoth to the VM's tap address (system/claudebox.nix)
      claudebox = {
        HostName = "10.100.0.2";
        User = "claude";
        ProxyJump = "hugh@${config.var.homelab.thoth}";
      };
      # Tailnet: Tailscale SSH via MagicDNS
      claudeboxtail = {
        HostName = "claudebox";
        User = "claude";
      };
    };
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
