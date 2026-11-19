{ pkgs, config, ... }:
{
  services.openssh = {
    enable = true;

    # https://search.nixos.org/options?channel=unstable&query=fail2ban&type=options#show=option%253Aservices.fail2ban.jails
    # prefed for fail2ban jails
    settings.LogLevel = "VERBOSE";
  };
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      # only ignore client hosts, servers should really not be sshing to each other
      config.var.homelab.d4080
      config.var.homelab.t14
    ];
  };
}
