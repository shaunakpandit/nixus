{ config, ... }:
{
  # Samba has its own password db. One-time: sudo smbpasswd -a <user>
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global."hosts allow" = "192.168.4. 100. 127.0.0.1";
      media = {
        path = "/data/media";
        "valid users" = config.var.username;
        "read only" = "no";
        "force group" = "media";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
