{ config, pkgs, ... }:
{
  home.username = "void";
  home.homeDirectory = "/home/void";

  xdg.configFile."tmux" = {
    source = ./dotfiles/tmux/.config/tmux;
    recursive = true;
  };

  xdg.configFile."ghostty" = {
    source = ./dotfiles/ghostty/.config/ghostty;
    recursive = true;
  };

  xdg.configFile."nvim" = {
    source = builtins.filterSource (
      path: type: baseNameOf path != "nvim-pack-lock.json"
    ) ./dotfiles/nvim/.config/nvim;
    recursive = true;
  };

  home.packages = with pkgs; [
    fastfetch
    ripgrep
    rustup
    fd
    fzf
    lua-language-server
    nil
    nixpkgs-fmt
    nodejs
  ];

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

  programs.zoxide = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
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

  wayland.windowManager.mango = {
    enable = true;
    settings = ''
      		bind=SUPER,r,reload_config
      		bind=SUPER,Return,spawn,ghostty
      		bind=SUPER,d,spawn,wmenu-run -l 10
      		bind=SUPER,q,killclient,
      		bind=SUPER,b,spawn,firefox
      		bind=SUPER,h,focusdir,left
      		bind=SUPER,j,focusdir,down
      		bind=SUPER,k,focusdir,up
      		bind=SUPER,l,focusdir,right	
      		bind=SUPER,1,view,1
      		bind=SUPER,2,view,2
      		bind=SUPER,3,view,3
      		bind=SUPER,4,view,4
      		bind=SUPER,5,view,5
      		bind=SUPER+SHIFT,1,tagsilent,1	
      		bind=SUPER+SHIFT,2,tagsilent,2	
      		bind=SUPER+SHIFT,3,tagsilent,3	
      		bind=SUPER+SHIFT,4,tagsilent,4	
      		bind=SUPER+SHIFT,5,tagsilent,5	
      		bind=SUPER+SHIFT,h,exchange_client,left
      		bind=SUPER+SHIFT,j,exchange_client,down
      		bind=SUPER+SHIFT,k,exchange_client,up
      		bind=SUPER+SHIFT,l,exchange_client,right	
      		repeat_rate=70
      		repeat_delay=200
      		xkb_rules_layout=us
      		xkb_rules_options=caps:ctrl_modifier,altwin:swap_lalt_lwin
    '';
    autostart_sh = ''
      		exec-once=waybar
      	    '';
  };
  home.stateVersion = "25.11";
}
