{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers = {
    portainer = {
      image = "portainer/portainer-ce:latest";
      # see https://www.reddit.com/r/NixOS/comments/1h63nvw/comment/m0ba11y/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      pull = "always";

      # 9443 for HTTPS, 8000 for Edge Agent
      ports = [
        "8000:8000"
        "9443:9443"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/portainer/data:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];

      extraOptions = [
        "--restart=unless-stopped"
      ];
    };
  };
}
