{ config, ... }:
{
  # Samba keeps its own password db: set it once with `sudo smbpasswd -a <user>`.
  services.samba = {
    enable = true;
    openFirewall = true;
    settings.media = {
      path = "/mnt/media";
      "valid users" = config.var.username;
      "read only" = "no";
      "force group" = "users";
      "create mask" = "0664";
      "directory mask" = "0775";
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
