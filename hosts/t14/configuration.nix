{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./variables.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
    ../../system/profiles/desktop.nix
    ../../system/laptop.nix
    ../../system/cachyos.nix
    ../../system/gaming
    ../../system/sops.nix
  ];

  # TODO: set as 'pkgs.linuxPackages_latest;' on first build
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  sops = {
    # No openssh host key on t14, so the admin key decrypts too. /home is on the root fs, so it's readable at boot.
    age.keyFile = "/home/void/.config/sops/age/keys.txt";
    # root's key for the thoth remote builder; its public half is in hosts/thoth/configuration.nix
    secrets.nixbuild_ssh_key = { };
    # Symlinked to where home/shell/claudeCode.nix reads it
    secrets.openrouter_api_key = {
      owner = config.var.username;
      path = "/home/void/.config/openrouter/api_key";
    };
  };

  # Offload builds to thoth; falls back to building locally when thoth is unreachable.
  # test with sudo nix store info --store ssh-ng://hugh@<thoth ip>
  nix.distributedBuilds = true;
  # thoth fetches from caches itself instead of pulling everything through the laptop
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = config.var.homelab.thoth;
      sshUser = "hugh";
      sshKey = config.sops.secrets.nixbuild_ssh_key.path;
      protocol = "ssh-ng";
      system = "x86_64-linux";
      maxJobs = 8;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
  ];
  # Pins thoth's host key so root's non-interactive ssh doesn't stall on the fingerprint prompt.
  # Get it with `ssh-keyscan -t ed25519 <thoth ip>` (drop the leading IP),
  # or `cat /etc/ssh/ssh_host_ed25519_key.pub` on thoth.
  programs.ssh.knownHosts.thoth = {
    hostNames = [ config.var.homelab.thoth ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJg5rB28CPMtl44xAIjSkdyEuZlh99Iw5+LlM+5O6F/C root@nixos";
  };

  environment.systemPackages = [ pkgs.compose2nix ];

  system.stateVersion = "25.11"; # Release of the first install; never change it.
}
