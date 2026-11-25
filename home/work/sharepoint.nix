# Mounts SharePoint at ~/SharePoint. Create the `sharepoint` remote once with `rclone config`
# (onedrive -> SharePoint site): it holds a rotating OAuth token, so it is state, not Nix config.
{ pkgs, ... }:
{
  home.packages = [ pkgs.rclone ];

  systemd.user.services.sharepoint = import ../rcloneMount.nix pkgs "sharepoint" "SharePoint";
}
