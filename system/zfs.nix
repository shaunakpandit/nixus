{ ... }:
{
  boot.supportedFilesystems.zfs = true;
  # Root is ext4, so only data pools are imported.
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;
}
