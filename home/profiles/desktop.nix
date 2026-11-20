# Linux desktop on mango. Pair with system/profiles/desktop.nix.
{
  imports = [
    ./base.nix
    ../mango
    ../ghostty.nix
    ../librewolf.nix
    ../waybar.nix
    ../fuzzel.nix
    ../feh.nix
    ../sioyek.nix
    ../easyeffects.nix
    ../iptvnator.nix
    ../idleSuspend.nix
    ../shell/cliamp.nix
    ../shell/newsboat.nix
    ../shell/claudeCodeNative.nix
  ];
}
