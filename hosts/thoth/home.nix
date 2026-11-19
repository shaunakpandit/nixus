{ lib, ... }:
{
  imports = [
    ./variables.nix
    ../../home/profiles/base.nix
    ../../home/shell/claudeCodeNative.nix
  ];

  # thoth reaches the VM's tap directly, no jump through itself.
  programs.ssh.settings.claudebox.ProxyJump = lib.mkForce null;

  home.stateVersion = "26.05";
}
