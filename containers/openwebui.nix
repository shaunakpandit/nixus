{ config, pkgs, ... }:
{
  # see https://github.com/open-webui/open-webui#installing-open-webui-with-bundled-ollama-support
  virtualisation.oci-containers.containers = {
    open-webui = {
      image = "ghcr.io/open-webui/open-webui:latest";
      # see https://www.reddit.com/r/NixOS/comments/1h63nvw/comment/m0ba11y/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      pull = "always";

      ports = [
        "3000:8080"
      ];

      volumes = [
        # "ollama:/root/.ollama"
        "open-webui:/app/backend/data "
      ];

      extraOptions = [
        # "--restart=unless-stopped"
        # "--gpus=all"
      ];
    };
  };
}
