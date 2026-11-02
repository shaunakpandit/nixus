{ config, inputs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    # Encrypted to the recipients in .sops.yaml, so it's safe to commit.
    defaultSopsFile = ../secrets/secrets.yaml;
    # Decrypt with the host's SSH key so no extra key file has to be provisioned.
    # Requires services.openssh (system/fail2ban.nix).
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.openrouter_api_key.owner = config.var.username;
  };
}
