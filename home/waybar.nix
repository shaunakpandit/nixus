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
        modules-left = [
          "mango/workspaces"
          # "mango/window"
          "mango/layout"
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

        "mango/window" = {
          format = "{}";
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
