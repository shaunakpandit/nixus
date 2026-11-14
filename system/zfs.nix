{ ... }:
{
  # One-time pool setup (destroys the disk), then rebuild:
  #   ls -l /dev/disk/by-id | grep sdb
  #   sudo zpool create -o ashift=12 -O compression=zstd -O atime=off -O xattr=sa \
  #     -O acltype=posixacl -O mountpoint=none tank /dev/disk/by-id/<id>
  #   sudo zfs create -o mountpoint=legacy -o recordsize=1M tank/media
  #   sudo zfs create -o mountpoint=legacy tank/state
  # Redundancy later: `sudo zpool attach tank <existing-id> <new-id>` makes a mirror.
  # A single disk can't become raidz in place; build a raidz pool from 3+ disks and migrate.
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # Legacy mountpoints so NixOS owns the mounts and services wait for them.
  fileSystems."/data/media" = {
    device = "tank/media";
    fsType = "zfs";
  };
  fileSystems."/data/.state" = {
    device = "tank/state";
    fsType = "zfs";
  };
}
