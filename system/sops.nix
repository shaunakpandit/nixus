{ config, ... }:
{
  # Each host decrypts only its own file; recipients are set in .sops.yaml.
  # Secrets are decrypted at activation into /run/secrets (tmpfs), never the Nix store.
  sops.defaultSopsFile = ../secrets/${config.var.hostname}.yaml;
}
