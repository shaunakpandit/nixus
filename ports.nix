# Container port parsing, shared by system/virtualisation.nix (firewall), checks.nix (tests) and
# the report: `nix eval --raw .#ports.<host>` lists everything a host exposes and which file opened it.
# shortcut: per-interface openings (networking.firewall.interfaces) aren't listed; add them when a host uses one.
{ lib }:
rec {
  # Host side of a Docker port spec: "8089:80/tcp", "127.0.0.1:2375:2375", "[::]:53:53/udp",
  # "25500-25600:25500-25600". Fields are read from the end, so IPv6 addresses don't matter.
  # [] when Docker picks the host port ("8080", "0.0.0.0::80").
  publishedPort =
    spec:
    let
      parts = lib.splitString "/" spec;
      fields = lib.splitString ":" (lib.head parts);
      count = lib.length fields;
      hostPort = lib.elemAt fields (count - 2);
      address = lib.concatStringsSep ":" (lib.take (count - 2) fields);
      bounds = map lib.toInt (lib.splitString "-" hostPort);
    in
    lib.optional (count >= 2 && hostPort != "") {
      protocol = if lib.length parts == 2 then lib.last parts else "tcp";
      from = lib.head bounds;
      to = lib.last bounds;
      hostOnly =
        lib.hasPrefix "127." address
        || lib.elem address [
          "localhost"
          "::1"
          "[::1]"
        ];
    };

  report =
    host:
    let
      firewall = host.options.networking.firewall;
      source =
        file:
        if lib.hasInfix "/nixos/modules/" file then
          "nixpkgs " + lib.last (lib.splitString "/nixos/modules/" file)
        else
          lib.last (lib.splitString "-source/" file);
      show =
        port:
        if builtins.isInt port then
          toString port
        else if port.from == port.to then
          toString port.from
        else
          "${toString port.from}-${toString port.to}";
      # Published container ports are listed per container below, not as virtualisation.nix's openings.
      opened =
        protocol: option:
        lib.concatMap
          (definition: map (port: "${protocol}\t${show port}\t${source definition.file}") definition.value)
          (
            lib.filter (
              definition: !lib.hasSuffix "system/virtualisation.nix" definition.file
            ) option.definitionsWithLocations
          );
      note =
        spec:
        let
          parsed = publishedPort spec;
        in
        if parsed == [ ] then
          " (random host port)"
        else if (lib.head parsed).hostOnly then
          " (host only)"
        else
          "";
      published = lib.concatLists (
        lib.mapAttrsToList (
          name: container: map (spec: "docker\t${spec}\tcontainer ${name}${note spec}") container.ports
        ) host.config.virtualisation.oci-containers.containers
      );
    in
    lib.concatLines (
      opened "tcp" firewall.allowedTCPPorts
      ++ opened "tcp" firewall.allowedTCPPortRanges
      ++ opened "udp" firewall.allowedUDPPorts
      ++ opened "udp" firewall.allowedUDPPortRanges
      ++ published
    );
}
