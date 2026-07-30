{
  config,
  pkgs,
  inputs,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
    waybar
    jq
  ];

  programs.waybar = {
    enable = true;
    settings = [
      {
        modules-left = [
          "ext/workspaces"
          "dwl/window"
        ];

        modules-center = [
          "cpu"
          "clock"
          "memory"
        ];

        modules-right = [
          "network"
          "pulseaudio"
          "backlight"
          "disk"
          "temperature"
          "battery"
        ];

        "ext/workspaces" = {
          format = "{icon}";
          ignore-hidden = false;
          on-click = "activate";
          on-click-right = "deactivate";
          sort-by-id = true;
        };

        "clock" = {
          format = "{:%Y-%m-%d %H:%M}";
        };

        "cpu" = {
          interval = 1;
          format = "cpu {usage}%";
        };

        "memory" = {
          interval = 1;
          format = "{used} GB ram";
        };

        "network" = {
          interval = 1;
          format = "{bandwidthTotalBytes} {ipaddr}";
        };

        "disk" = {
          format = "{used}";
        };

        "dwl/window" = {
          format = "[{layout}] {app_id}";
        };
      }
    ];
    style = ''
      #workspaces button.active {
          color: #${c.base0B};
          border-radius: 0px;
          border-bottom: 0px solid transparent;
          box-shadow: none;
      } 
    '';
  };
}
