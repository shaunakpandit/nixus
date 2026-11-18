# Shared with the claudebox VM (system/claudebox.nix).
{
  programs.tmux.enable = true;

  xdg.configFile."tmux" = {
    source = ../../dots/tmux;
    recursive = true;
  };

  home.shellAliases = {
    tm = "tmux new -A -s code -n code ';' neww -d -S -t code: -n term ';' neww -d -S -t code: -n frenchie";
    tmm = "tmux new -A -s gen -n gen ';' neww -d -S -t gen: -n shell";
    tmn = "tmux new -A -s notes -n notes";
  };
}
