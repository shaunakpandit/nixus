# Work laptops: the desktop plus docker (system/virtualisation.nix), a tailscale client, and Intune enrollment. Pair with home/profiles/work.nix.
{ ... }:
{
  imports = [
    ./desktop.nix
    ../virtualisation.nix
  ];

  # Client only; system/tailscale.nix is the homelab-server variant. Switch tailnets with `tailscale switch`.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Linux Intune is compliance-only and Microsoft supports only Ubuntu/RHEL; see the intune-portal app to enroll.
  services.intune.enable = true;
}
