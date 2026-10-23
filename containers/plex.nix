{ config, ... }:

let
  # Match these to the owner/group that can read your media.
  plexUid = "1000";
  plexGid = "100";

  configDir = "/var/lib/plex/config";
  transcodeDir = "/var/lib/plex/transcode";
  mediaDir = "/mnt/media";
in
{
  systemd.tmpfiles.rules = [
    "d ${configDir} 0750 ${plexUid} ${plexGid} -"
    "d ${transcodeDir} 0750 ${plexUid} ${plexGid} -"
  ];

  virtualisation.oci-containers.containers.plex = {
    image = "plexinc/pms-docker:latest";
    # see https://www.reddit.com/r/NixOS/comments/1h63nvw/comment/m0ba11y/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    pull = "always";

    environment = {
      TZ = if config.time.timeZone != null then config.time.timeZone else "Etc/UTC";

      PLEX_UID = plexUid;
      PLEX_GID = plexGid;

      NVIDIA_VISIBLE_DEVICES = "all";
      NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
    };

    # Keep the claim token outside the world-readable Nix store.
    environmentFiles = [
      "/etc/plex.env"
    ];

    volumes = [
      "${configDir}:/config"
      "${transcodeDir}:/transcode"
      "${mediaDir}:/data:ro"
    ];

    extraOptions = [
      "--network=host"
      "--gpus=all"
    ];
  };

  # Ensure configured filesystem mounts are available before starting Plex.
  systemd.services.docker-plex.unitConfig.RequiresMountsFor = [
    configDir
    transcodeDir
    mediaDir
  ];
}
