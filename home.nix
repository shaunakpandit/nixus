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
  imports = [
    ./home/nvim.nix
    ./home/shell.nix
    ./home/mango
    ./home/utils.nix
  ];

  home.username = "void";
  home.homeDirectory = "/home/void";

  home.packages = with pkgs; [
    waybar
    wmenu
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
          "disk"
          "temperature"
          "battery"
        ];

        "ext/workspaces" = {
          format = "{icon}";
          ignore-hidden = true;
          on-click = "activate";
          on-click-right = "deactivate";
          sort-by-id = true;
        };

        "cpu" = {
          interval = 1;
          format = "cpu {usage}%";
        };

        "memory" = {
          interval = 1;
          format = "{percentage}% ram";
        };

        "dwl/window" = {
          format = "[{layout}] {title}";
        };
      }
    ];
  };

  programs.firefox = {
    enable = true;
    profiles = {
      void = {
        isDefault = true;
        extensions = {
          force = true;

          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            darkreader
            proton-pass
            vimium
          ];
        };
        settings = {
          # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
  };

  stylix.targets.firefox = {
    enable = true;
    colorTheme.enable = true;
    colors.enable = true;
    fonts.enable = true;
    profileNames = [ "void" ];
  };

  home.stateVersion = "25.11";
}
