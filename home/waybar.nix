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
    fonts.enable = true;
  };

  programs.waybar = {
    enable = true;
    package = inputs.waybar-git.packages.${pkgs.system}.default;
    settings = [
      {
        position = "bottom";
        height = 24;

        modules-left = [
          "mango/workspaces"
          "mango/layout"
          "mango/window"
        ];

        modules-center = [
          "clock"
          "cpu"
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

        # "mango/workspaces" = {
        #   "format" = "{icon}";
        #   "format-icons" = {
        #     "1" = "一";
        #     "2" = "二";
        #     "active" = "";
        #     "default" = "";
        #     "urgent" = "";
        #     "empty" = "";
        #   };
        #   "on-click" = "activate";
        #   "on-click-right" = "toggle";
        #   "overview-label" = "";
        # };

        "mango/window" = {
          "format" = " {title}";
          "rewrite" = {
            ".*" = "";
            "(.*) - Mozilla Firefox" = "🌎 $1";
            "(.*) - zsh" = "> [$1]";
          };
          "icon" = true;
          "icon-size" = 20;
        };

        "mango/workspaces" = {
          "format" = "{value}";
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
          format = "{usage}% ";
        };

        "memory" = {
          interval = 1;
          max-length = 10;
          format = "{used:.2f}GB ";
        };

        "network" = {
          interval = 1;
          format = "{essid}   {bandwidthTotalBytes} {ipaddr}";
          # format-wifi = "{essid} ({signalStrength}%) ";
        };

        "disk" = {
          format = "{used}";
        };
      }
    ];
    style = ''
      * {
        font-size: 14px;
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
