{ config, pkgs, ... }:
{
  # see https://github.com/plexinc/pms-docker/blob/master/README.md
  virtualisation.oci-containers.containers."plex" = {
    image = "";

    pull = "always";
    extraOptions = [
      "--restart=unless-stopped"
      "--gpus=all"
    ];
  };
}
