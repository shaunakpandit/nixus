{ pkgs, ... }:
# Ported from https://github.com/CachyOS/CachyOS-Settings
{
  boot = {
    # Wine/Proton NT synchronization primitives, used by GE-Proton when present
    kernelModules = [ "ntsync" ];
    # zswap would sit in front of zram and hide its compressed pages
    kernelParams = [ "zswap.enabled=0" ];
    blacklistedKernelModules = [
      "iTCO_wdt"
      "sp5100_tco"
      "wdat_wdt"
    ];
    kernel.sysctl = {
      # high swappiness suits zram: compressing anon pages is cheaper than rereading page cache from disk
      "vm.swappiness" = 150;
      "vm.page-cluster" = 0;
      "vm.vfs_cache_pressure" = 50;
      # flush writeback in smaller, steadier batches so big downloads don't stall the game
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "kernel.nmi_watchdog" = 0;
      "net.core.netdev_max_backlog" = 4096;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 100;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
  '';

  systemd.tmpfiles.rules = [
    "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    # split THPs that are mostly zero pages to curb THP=always memory bloat
    "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
  ];

  # esync (Proton's fallback without ntsync) needs a file descriptor per sync object
  systemd.settings.Manager.DefaultLimitNOFILE = "2048:2097152";
  systemd.user.settings.Manager.DefaultLimitNOFILE = "1024:1048576";

  # automatic process priorities, with CachyOS' rule set for games, compositors and audio
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # proton-cachyos isn't in nixpkgs, GE-Proton is the closest packaged equivalent
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
}
