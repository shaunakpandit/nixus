{ lib, pkgs, ... }:

let
  uid = "1000";
  gid = "100";

  timezone = "Etc/UTC";
  port = 6060;

  dbPassword = "CHANGE_ME_APP_PASSWORD";
  dbRootPassword = "CHANGE_ME_ROOT_PASSWORD";

  dataDir = "/var/lib/grimmory";
  networkName = "grimmory";

  docker = "${pkgs.docker}/bin/docker";
in
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  systemd.tmpfiles.rules = [
    "d ${dataDir}                0750 ${uid} ${gid} -"
    "d ${dataDir}/data           0750 ${uid} ${gid} -"
    "d ${dataDir}/books          0750 ${uid} ${gid} -"
    "d ${dataDir}/bookdrop       0750 ${uid} ${gid} -"
    "d ${dataDir}/mariadb        0750 ${uid} ${gid} -"
    "d ${dataDir}/mariadb/config 0750 ${uid} ${gid} -"
  ];

  systemd.services.grimmory-network = {
    description = "Docker network for Grimmory";

    requires = [ "docker.service" ];
    after = [ "docker.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      if ! ${docker} network inspect ${networkName} >/dev/null 2>&1; then
        ${docker} network create ${networkName}
      fi
    '';
  };

  virtualisation.oci-containers.containers = {
    grimmory-mariadb = {
      image = "lscr.io/linuxserver/mariadb:11.4.5";
      autoStart = true;

      environment = {
        PUID = uid;
        PGID = gid;
        TZ = timezone;

        MYSQL_DATABASE = "grimmory";
        MYSQL_USER = "grimmory";
        MYSQL_PASSWORD = dbPassword;
        MYSQL_ROOT_PASSWORD = dbRootPassword;
      };

      volumes = [
        "${dataDir}/mariadb/config:/config"
      ];

      extraOptions = [
        "--network=${networkName}"
        "--network-alias=mariadb"
        "--health-cmd=mariadb-admin ping -h localhost"
        "--health-interval=5s"
        "--health-timeout=5s"
        "--health-retries=10"
      ];
    };

    grimmory = {
      image = "grimmory/grimmory:latest";
      autoStart = true;

      dependsOn = [ "grimmory-mariadb" ];

      environment = {
        USER_ID = uid;
        GROUP_ID = gid;
        TZ = timezone;

        DATABASE_URL = "jdbc:mariadb://mariadb:3306/grimmory";
        DATABASE_USERNAME = "grimmory";
        DATABASE_PASSWORD = dbPassword;

        SERVER_PORT = toString port;
      };

      ports = [
        "${toString port}:${toString port}"
      ];

      volumes = [
        "${dataDir}/data:/app/data"
        "${dataDir}/books:/books"
        "${dataDir}/bookdrop:/bookdrop"
      ];

      extraOptions = [
        "--network=${networkName}"
      ];
    };
  };

  systemd.services.docker-grimmory-mariadb = {
    requires = [ "grimmory-network.service" ];

    after = [
      "grimmory-network.service"
      "systemd-tmpfiles-setup.service"
    ];
  };

  systemd.services.docker-grimmory = {
    requires = [ "grimmory-network.service" ];

    after = [
      "grimmory-network.service"
      "systemd-tmpfiles-setup.service"
    ];

    serviceConfig.TimeoutStartSec = lib.mkForce "180s";

    # dependsOn orders container startup; this also waits for DB health.
    preStart = lib.mkAfter ''
      echo "Waiting for Grimmory MariaDB to become healthy..."

      for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
        status="$(${docker} inspect \
          --format '{{.State.Health.Status}}' \
          grimmory-mariadb 2>/dev/null || true)"

        if [ "$status" = "healthy" ]; then
          exit 0
        fi

        sleep 2
      done

      echo "MariaDB did not become healthy within 120 seconds." >&2
      exit 1
    '';
  };
}
