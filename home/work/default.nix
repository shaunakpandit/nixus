{ pkgs, ... }:
{
  imports = [
    ./dev.nix
    ./thunderbird.nix
    ./sharepoint.nix
    ./teams.nix
  ];

  home.packages = with pkgs; [
    # MySQL GUI; enable its Vim keymap in settings
    beekeeper-studio
  ];

  programs.git.settings.user.email = "shaunak@thea.study";
}
