# Provides pkgs.cachyosKernels; each host still picks its own boot.kernelPackages.
{ inputs, ... }:
{
  # Uses this repo's nixpkgs, so a kernel module can occasionally mismatch.
  # overlays.pinned uses upstream's exact nixpkgs instead: always cached, but a second nixpkgs instance.
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];

  nix.settings.substituters = [ "https://cache.lantian.pub/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
}
