# Headless homelab servers running containers/. Pair with home/profiles/base.nix.
# The host must add its own IP to homelab.nix (tailscale advertises it).
{ config, pkgs, ... }:
{
  imports = [
    ./base.nix
    ../fail2ban.nix
    ../tailscale.nix
    ../virtualisation.nix
  ];

  users.users.${config.var.username}.extraGroups = [ "docker" ];

  # for sshing with x256 color terminals
  environment.enableAllTerminfo = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    compose2nix
  ];
}
