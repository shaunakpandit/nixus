# Isolated microVM where Claude runs with full permissions: internet only, no LAN/tailnet/host services.
{ lib, pkgs, ... }:
let
  tap = "vm-claude";
  # Everything the guest must not reach, dropped in the raw table so Docker's DNAT can't route around it.
  blocked = [
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "100.64.0.0/10"
    "169.254.0.0/16"
  ];
  rules =
    flag:
    lib.concatMapStringsSep "\n" (
      range: "iptables -t raw ${flag} PREROUTING -i ${tap} -d ${range} -j DROP || true"
    ) blocked;
in
{
  microvm.vms.claudebox.config = {
    microvm = {
      hypervisor = "qemu";
      vcpu = 2;
      mem = 4096;
      interfaces = [
        {
          type = "tap";
          id = tap;
          mac = "02:00:00:c1:a0:de";
        }
      ];
      volumes = [
        {
          image = "home.img";
          mountPoint = "/home";
          size = 40960;
        }
        {
          image = "nix-rw.img";
          mountPoint = "/nix/.rw-store";
          size = 20480;
        }
      ];
      writableStoreOverlay = "/nix/.rw-store";
    };

    networking.hostName = "claudebox";
    networking.enableIPv6 = false;
    systemd.network = {
      enable = true;
      networks."20-lan" = {
        matchConfig.Type = "ether";
        address = [ "10.100.0.2/24" ];
        gateway = [ "10.100.0.1" ];
        dns = [ "1.1.1.1" ];
      };
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    users.users.claude = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmL0OiFEZ/l2usxzvKkje514gDkfUg6JpArW7CoguxX shaunakdpandit@gmail.com"
      ];
    };
    security.sudo.wheelNeedsPassword = false;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    environment.systemPackages = with pkgs; [
      claude-code
      git
      gh
      ripgrep
      fd
      jq
      curl
      tmux
      nodejs
      python3
      gcc
    ];

    system.stateVersion = "26.05";
  };

  systemd.network = {
    enable = true;
    networks."20-${tap}" = {
      matchConfig.Name = tap;
      address = [ "10.100.0.1/24" ];
    };
  };
  networking.networkmanager.unmanaged = [ tap ];
  networking.nat = {
    enable = true;
    internalInterfaces = [ tap ];
    externalInterface = "enp5s0";
  };
  # Delete first so firewall reloads do not stack duplicate rules.
  networking.firewall.extraCommands = rules "-D" + "\n" + rules "-I";
  networking.firewall.extraStopCommands = rules "-D";
}
