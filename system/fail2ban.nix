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
      "192.16.4.30" # d4080
      "192.16.4.28" # thoth
      "192.16.4.22" # t14
    ];
  };
}
