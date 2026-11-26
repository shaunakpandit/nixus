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
      broken = hosts.rama.extendModules {
        modules = [ { networking.networkmanager.insertNameservers = lib.mkForce [ "127.0.0.1" ]; } ];
      };
    in
    assert lib.assertMsg (lib.any
      (assertion: !assertion.assertion && lib.hasPrefix "containers/pihole.nix" assertion.message)
      broken.config.assertions
    ) "containers/pihole.nix no longer catches a host that resolves only through itself.";
    pkgs.emptyFile;
}
