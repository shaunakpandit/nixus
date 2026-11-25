# Mounts SharePoint at ~/SharePoint. Create the `sharepoint` remote once with `rclone config`
# (onedrive -> SharePoint site): it holds a rotating OAuth token, so it is state, not Nix config.
{ pkgs, ... }:
{
  home.packages = [ pkgs.rclone ];

  systemd.user.services.sharepoint = {
    Unit = {
      Description = "Mount SharePoint with rclone";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "notify";
      # fusermount3 is a setuid wrapper
      Environment = "PATH=/run/wrappers/bin";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/SharePoint";
      ExecStart = "${pkgs.rclone}/bin/rclone mount sharepoint: %h/SharePoint --vfs-cache-mode full";
      ExecStop = "/run/wrappers/bin/fusermount3 -u %h/SharePoint";
      Restart = "on-failure";
      RestartSec = 30;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
