{ ... }:

{
  virtualisation.oci-containers.containers.crafty = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    autoStart = true;

    environment = {
      TZ = "Etc/UTC";
    };

    ports = [
      "8443:8443"
      "8123:8123"
      "19132:19132/udp"
      "25500-25600:25500-25600"
    ];

    volumes = [
      "/home/hugh/docker/backups:/crafty/backups"
      "/home/hugh/docker/logs:/crafty/logs"
      "/home/hugh/docker/servers:/crafty/servers"
      "/home/hugh/docker/config:/crafty/app/config"
      "/home/hugh/docker/import:/crafty/import"
    ];
  };
}
