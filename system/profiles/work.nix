# Work laptops: the desktop plus docker, a tailscale client, and Intune enrollment. Pair with home/profiles/work.nix.
{ config, pkgs, ... }:
{
  imports = [ ./desktop.nix ];

  # Client only; system/tailscale.nix is the homelab-server variant. Switch tailnets with `tailscale switch`.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Not system/virtualisation.nix: that one enables the nvidia container toolkit.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  users.users.${config.var.username}.extraGroups = [ "docker" ];
  environment.systemPackages = [ pkgs.docker-compose ];

  # Linux Intune is compliance-only and Microsoft supports only Ubuntu/RHEL; see the intune-portal app to enroll.
  services.intune.enable = true;
}
