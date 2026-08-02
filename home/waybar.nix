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
    jq
  ];

  stylix.targets.waybar = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    package = inputs.waybar-git.packages.${pkgs.system}.default;
    settings = [
      {
        modules-left = [
          "mango/workspaces"
          # "mango/window"
          "mango/layout"
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

        "mango/workspaces" = {
          "format" = "{icon}";
          "hide-empty" = false;
          "on-click" = "activate";
          "on-click-right" = "toggle";
          "overview-label" = "OVERVIEW";
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

        "mango/window" = {
          format = "{}";
        };
      }
    ];
    style = ''
      * {
        font-size: 14px;
        font-weight: 600;
      }
      #workspaces button.active {
          color: #${c.base0B};
          border-radius: 0px;
          border-bottom: 0px solid transparent;
          box-shadow: none;
      } 
    '';
  };
}
