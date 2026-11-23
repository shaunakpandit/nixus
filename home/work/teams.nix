{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  # shortcut: Fluent UI token names are read off Teams' web UI and may change with Teams updates; unknown ones are ignored.
  css = pkgs.writeText "teams-stylix.css" ''
    :root, .fui-FluentProvider {
      --colorNeutralBackground1: ${c.base00} !important;
      --colorNeutralBackground2: ${c.base01} !important;
      --colorNeutralBackground3: ${c.base01} !important;
      --colorNeutralForeground1: ${c.base05} !important;
      --colorNeutralForeground2: ${c.base04} !important;
      --colorNeutralForeground3: ${c.base04} !important;
      --colorNeutralStroke1: ${c.base02} !important;
      --colorBrandBackground: ${c.base0D} !important;
      --colorBrandForeground1: ${c.base0D} !important;
    }
  '';
in
{
  home.packages = [ pkgs.teams-for-linux ];

  # Read-only, so the in-app Settings -> Theme menu can't save; change settings here.
  xdg.configFile."teams-for-linux/config.json".text = builtins.toJSON {
    app.title = "Teams";
    # Frameless makes Teams' own top bar the draggable title bar
    window.frame = false;
    # mango has no tray
    tray.enabled = false;
    appearance = {
      followSystemTheme = true;
      cssLocation = "${css}";
    };
    # Sends notifications to dunst instead of in-window
    notifications.method = "electron";
    idleDetection.setAwayOnIdle = true;
    screenSharing.resolution = {
      enabled = true;
      mode = "remove";
    };
    auth.intune = {
      enabled = true;
      user = "shaunak@thea.study";
    };
  };
}
