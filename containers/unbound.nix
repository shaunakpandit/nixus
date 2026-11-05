{ pkgs, ... }:

let
  # Recursive resolver config based on https://docs.pi-hole.net/guides/dns/unbound/
  unboundConfig = pkgs.writeText "unbound.conf" ''
    server:
      verbosity: 0
      use-syslog: no
      logfile: ""

      interface: 0.0.0.0
      port: 5335
      do-ip4: yes
      do-ip6: no
      prefer-ip6: no
      do-udp: yes
      do-tcp: yes

      # Paths the mvance/unbound entrypoint prepares (chroot, trust anchor).
      username: "_unbound"
      directory: "/opt/unbound/etc/unbound"
      chroot: "/opt/unbound/etc/unbound"
      auto-trust-anchor-file: "var/root.key"

      harden-glue: yes
      harden-dnssec-stripped: yes
      use-caps-for-id: no
      edns-buffer-size: 1232
      prefetch: yes
      num-threads: 1

      # Docker NAT preserves client source IPs, so allow LAN, docker, and tailnet.
      access-control: 0.0.0.0/0 refuse
      access-control: 127.0.0.0/8 allow
      access-control: 10.0.0.0/8 allow
      access-control: 172.16.0.0/12 allow
      access-control: 192.168.0.0/16 allow
      access-control: 100.64.0.0/10 allow

      private-address: 10.0.0.0/8
      private-address: 172.16.0.0/12
      private-address: 192.168.0.0/16
      private-address: 169.254.0.0/16
      private-address: 100.64.0.0/10
  '';
in
{
  virtualisation.oci-containers.containers.unbound = {
    image = "mvance/unbound:latest";
    pull = "always";
    # Listens on the LAN so pihole (and gatus on thoth) can reach it.
    ports = [
      "5335:5335/tcp"
      "5335:5335/udp"
    ];
    volumes = [ "${unboundConfig}:/opt/unbound/etc/unbound/unbound.conf:ro" ];
  };
}
