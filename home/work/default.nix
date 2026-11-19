{ pkgs, ... }:
{
  imports = [
    ./dev.nix
    ./thunderbird.nix
    ./sharepoint.nix
  ];

  home.packages = with pkgs; [
    teams-for-linux
    # MySQL GUI; enable its Vim keymap in settings
    beekeeper-studio
  ];

  programs.git.settings.user.email = "shaunak@thea.study";
}
