# Mounts Proton Drive at ~/ProtonDrive. Needs the protondrive_* sops secrets from the host.
# rclone-config rewrites ~/.config/rclone/rclone.conf on every login, wiping hand-made remotes.
{ config, osConfig, ... }:
let
  secret = name: osConfig.sops.secrets.${name}.path;
in
{
  programs.rclone = {
    enable = true;
    remotes.protondrive = {
      config.type = "protondrive";
      secrets = {
        username = secret "protondrive_username";
        password = secret "protondrive_password";
        # rclone generates the 2FA code from this TOTP seed
        otp_secret_key = secret "protondrive_otp_secret";
      };
      mounts."" = {
        enable = true;
        mountPoint = "${config.home.homeDirectory}/ProtonDrive";
        options.vfs-cache-mode = "full";
      };
    };
  };
}
