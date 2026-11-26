# Notification daemon; colors and font come from stylix
{ lib, pkgs, ... }:
{
  services.dunst.enable = true;

  # cliamp's notify API looks up notify-send on PATH
  home.packages = [ pkgs.libnotify ];

  # Sourced by dots/tmux/tmux.conf. A bell in any window becomes a notification.
  xdg.configFile."tmux/notify.conf".text = ''
    set-hook -g alert-bell 'run-shell -b "${lib.getExe' pkgs.libnotify "notify-send"} -a tmux #{q:session_name}:#{q:window_name} #{q:pane_title}"'
  '';

  # Ring the bell (not Ghostty's escape, which tmux swallows) on permission and input prompts
  programs.claude-code.settings.preferredNotifChannel = "terminal_bell";
}
