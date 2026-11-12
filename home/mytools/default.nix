{ lib, ... }:
{
  # Every other .nix file here is a tool module; new ones still need `git add`.
  imports = map (name: ./${name}) (
    lib.filter (name: name != "default.nix" && lib.hasSuffix ".nix" name) (
      lib.attrNames (builtins.readDir ./.)
    )
  );
}
