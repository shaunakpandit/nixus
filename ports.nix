# Everything a host exposes and which file opened it: `nix eval --raw .#ports.<host>`.
# Docker-published container ports bypass the NixOS firewall, so they're listed separately.
# shortcut: per-interface openings (networking.firewall.interfaces) aren't listed; add them when a host uses one.
host:
let
  inherit (host.pkgs) lib;
  firewall = host.options.networking.firewall;
  source =
    file:
    if lib.hasInfix "/nixos/modules/" file then
      "nixpkgs " + lib.last (lib.splitString "/nixos/modules/" file)
    else
      lib.last (lib.splitString "-source/" file);
  show =
    port: if builtins.isInt port then toString port else "${toString port.from}-${toString port.to}";
  opened =
    protocol: option:
    lib.concatMap (
      definition: map (port: "${protocol}\t${show port}\t${source definition.file}") definition.value
    ) option.definitionsWithLocations;
  published = lib.concatLists (
    lib.mapAttrsToList (
      name: container: map (port: "docker\t${port}\tcontainer ${name}") container.ports
    ) host.config.virtualisation.oci-containers.containers
  );
in
lib.concatLines (
  opened "tcp" firewall.allowedTCPPorts
  ++ opened "tcp" firewall.allowedTCPPortRanges
  ++ opened "udp" firewall.allowedUDPPorts
  ++ opened "udp" firewall.allowedUDPPortRanges
  ++ published
)
