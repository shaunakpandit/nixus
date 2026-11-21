# Shared with the claudebox VM (system/claudebox.nix).
{
  programs.tmux.enable = true;

  xdg.configFile."tmux" = {
    source = ../../dots/tmux;
    recursive = true;
  };

  home.shellAliases = {
    tm = "tmux new -A -s main -n nvim ';' neww -d -S -t main: -n shell ';' neww -d -S -t main: -n claude";
    tmm = "tmux new -A -s general -n term ';' neww -d -S -t general: -n runtime";
    tmc = "tmux new -A -s sessions -n claude2 ';' neww -d -S -t sessions: -n claude3";
    tmn = "tmux new -A -s notes -n notes";
  };
}
