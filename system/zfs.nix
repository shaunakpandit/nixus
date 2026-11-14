# One-time pool setup on rama (the pool lives on the disk, so Nix can't create it):
#   1. rebuild and reboot so the LTS kernel and zfs module are loaded
#   2. find the disk's stable id: ls -l /dev/disk/by-id | grep sdb
#   3. sudo zpool create -o ashift=12 -O compression=lz4 -O atime=off -O xattr=sa \
#        -O acltype=posixacl -O recordsize=1M -O mountpoint=legacy tank /dev/disk/by-id/<id>
#   4. reboot (or sudo mount /mnt/media) so fileSystems."/mnt/media" picks it up
# mountpoint=legacy hands mounting to fileSystems, so services can order after it with RequiresMountsFor.
# Growing to RAIDZ later: create a raidz pool from 3+ new disks,
# zfs snapshot tank@move && zfs send tank@move | zfs recv <newpool>, then point fileSystems at it.
{ ... }:
{
  boot.supportedFilesystems.zfs = true;
  # Root is ext4, so only data pools are imported.
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;
}
