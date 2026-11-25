# Mounts Proton Drive at ~/ProtonDrive. Create the `protondrive` remote once with `rclone config`
# (protondrive -> username, password, 2FA): it caches session tokens, so it is state, not Nix config.
{ pkgs, ... }:
{
  home.packages = [ pkgs.rclone ];

  systemd.user.services.protondrive = import ./rcloneMount.nix pkgs "protondrive" "ProtonDrive";
}
