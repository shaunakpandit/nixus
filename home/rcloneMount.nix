# A systemd user service that mounts an rclone remote at ~/<dir>.
pkgs: remote: dir: {
  Unit = {
    Description = "Mount ${dir} with rclone";
    After = [ "network-online.target" ];
  };
  Service = {
    Type = "notify";
    # fusermount3 is a setuid wrapper
    Environment = "PATH=/run/wrappers/bin";
    ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/${dir}";
    ExecStart = "${pkgs.rclone}/bin/rclone mount ${remote}: %h/${dir} --vfs-cache-mode full";
    ExecStop = "/run/wrappers/bin/fusermount3 -u %h/${dir}";
    Restart = "on-failure";
    RestartSec = 30;
  };
  Install.WantedBy = [ "default.target" ];
}
