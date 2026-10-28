{ ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # sudo install -d -m 700 /etc/tailscale
    # sudo install -m 600 /dev/null /etc/tailscale/authkey
    # sudoedit /etc/tailscale/authkey

    # Secret supplied outside the Nix store.
    authKeyFile = "/etc/tailscale/authkey";

    # Enable forwarding support for subnet routing.
    useRoutingFeatures = "server";

    extraUpFlags = [
      "--accept-dns=false"
      "--advertise-routes=192.168.4.28/32"
    ];
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    32400 # Plex
  ];

  # run the following to find tailscale IP of new device
  # failssscale ip -4
}
