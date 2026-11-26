# Lints, repo rules and regression tests for `nix flake check`. Rules about what a host must
# declare live as `assertions` in the feature that needs them; the regression tests below prove
# those assertions still catch the outage they were written for.
{
  pkgs,
  src,
  hosts,
}:
let
  inherit (pkgs) lib;
  # hardware-configuration.nix is generated per machine, so it stays as nixos-generate-config wrote it.
  nixFiles = lib.fileset.toSource {
    root = src;
    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (file: file.hasExt "nix" && file.name != "hardware-configuration.nix") src)
      (src + "/statix.toml")
    ];
  };
  check =
    name: tools: script:
    pkgs.runCommand name { nativeBuildInputs = tools; } ''
      cd ${nixFiles}
      ${script}
      touch $out
    '';
in
{
  format = check "format" [ pkgs.nixfmt-rs ] "nixfmt --check $(find . -name '*.nix')";
  statix = check "statix" [ pkgs.statix ] "statix check .";
  # `_name` marks an argument kept for its position, like filterSource's `path: _type:`.
  deadnix = check "deadnix" [ pkgs.deadnix ] "deadnix --fail --no-underscore .";

  repo-rules = check "repo-rules" [ ] ''
    fail() { echo "$1" >&2; exit 1; }

    # Comments may quote addresses (e.g. tailscale ACL snippets pasted elsewhere); code may not.
    if grep -rn --exclude=homelab.nix '192\.168\.4\.' . | grep -v '^[^:]*:[0-9]*: *#'; then
      fail "Hardcoded LAN address: use config.var.homelab.<name> from homelab.nix."
    fi

    cd ${src}
    if grep -rnIE 'PRIVATE KEY-{5}|sk-(ant|or)-[A-Za-z0-9_-]{20,}' .; then
      fail "Secret in the repo: everything here lands world-readable in /nix/store."
    fi

    extra=$(find hosts -mindepth 2 ! -name configuration.nix ! -name home.nix ! -name variables.nix ! -name hardware-configuration.nix)
    if [ -n "$extra" ]; then
      fail "$extra: a host directory holds only configuration.nix, home.nix, variables.nix and hardware-configuration.nix. Put features in system/, home/ or containers/."
    fi
  '';

  # The "tech tuesday" outage: rama resolved only through its own pihole, so the weekly restart
  # couldn't pull pihole's image. Rebuild that config and require the pihole assertion to fire.
  pihole-dns-fallback =
    let
      fires =
        servers:
        lib.any (assertion: !assertion.assertion && lib.hasPrefix "containers/pihole.nix" assertion.message)
          (hosts.rama.extendModules {
            modules = [ { networking.networkmanager.insertNameservers = lib.mkForce servers; } ];
          }).config.assertions;
    in
    assert lib.assertMsg (lib.all fires [
      [ "127.0.0.1" ]
      [ "127.0.0.53" ]
      [
        "127.0.0.1"
        "::1"
      ]
    ]) "containers/pihole.nix no longer catches a host that resolves only through itself.";
    pkgs.emptyFile;

  # The glance outage: containers reach each other through the host's address, and that traffic
  # goes through the NixOS firewall even though LAN traffic to the same ports doesn't. On every host,
  # each published container port must be open.
  published-ports-open =
    let
      inherit (import ./ports.nix { inherit lib; }) publishedPort;
      isOpen =
        firewall: port:
        let
          protocol = lib.toUpper port.protocol;
        in
        lib.any (open: open.from <= port.from && port.to <= open.to) (
          firewall."allowed${protocol}PortRanges"
          ++ map (number: {
            from = number;
            to = number;
          }) firewall."allowed${protocol}Ports"
        );
      closed = lib.concatLists (
        lib.mapAttrsToList (
          hostName: host:
          lib.concatMap (
            container:
            map (spec: "${hostName}: ${spec}") (
              lib.filter (
                spec:
                lib.any (port: !port.hostOnly && !isOpen host.config.networking.firewall port) (publishedPort spec)
              ) container.ports
            )
          ) (lib.attrValues host.config.virtualisation.oci-containers.containers)
        ) hosts
      );
    in
    assert lib.assertMsg (closed == [ ])
      "Published container ports closed in the firewall, so other containers can't reach them: ${lib.concatStringsSep ", " closed}";
    pkgs.emptyFile;

  port-parser =
    let
      inherit (import ./ports.nix { inherit lib; }) publishedPort;
      port = protocol: from: to: hostOnly: [
        {
          inherit
            protocol
            from
            to
            hostOnly
            ;
        }
      ];
      failures = lib.runTests {
        testPlain = {
          expr = publishedPort "3000:8080";
          expected = port "tcp" 3000 3000 false;
        };
        testUdp = {
          expr = publishedPort "53:53/udp";
          expected = port "udp" 53 53 false;
        };
        testRange = {
          expr = publishedPort "25500-25600:25500-25600";
          expected = port "tcp" 25500 25600 false;
        };
        testAddress = {
          expr = publishedPort "192.168.1.2:8089:80/tcp";
          expected = port "tcp" 8089 8089 false;
        };
        testLoopback = {
          expr = publishedPort "127.0.0.1:2375:2375";
          expected = port "tcp" 2375 2375 true;
        };
        testLocalhost = {
          expr = publishedPort "localhost:2375:2375";
          expected = port "tcp" 2375 2375 true;
        };
        testIpv6 = {
          expr = publishedPort "[::]:53:53/udp";
          expected = port "udp" 53 53 false;
        };
        testIpv6Loopback = {
          expr = publishedPort "[::1]:8080:80";
          expected = port "tcp" 8080 8080 true;
        };
        testRandomHostPort = {
          expr = publishedPort "0.0.0.0::80";
          expected = [ ];
        };
        testContainerOnly = {
          expr = publishedPort "8080";
          expected = [ ];
        };
      };
    in
    assert lib.assertMsg (failures == [ ]) "ports.nix publishedPort: ${builtins.toJSON failures}";
    pkgs.emptyFile;
}
