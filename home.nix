{
  config,
  pkgs,
  inputs,
  ...
}:
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
