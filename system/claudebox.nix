# Isolated microVM where Claude runs with full permissions: internet plus home DNS only, no LAN/tailnet/host services.
#
# One-time setup:
# 1. Tailnet policy (login.tailscale.com > Access controls). Edit, don't replace the file:
#      add     "tagOwners": { "tag:claudebox": ["autogroup:admin"] },
#      change  the allow-all grant's "src": ["*"] to "src": ["autogroup:member"]
#      append  to "ssh": { "action": "accept", "src": ["autogroup:member"], "dst": ["tag:claudebox"], "users": ["claude"] }
#    Tagged nodes aren't members, so claudebox can't reach out. Other tagged nodes need their own grants.
# 2. Auth key: Settings > Keys > Generate auth key, with tag:claudebox and not reusable.
#    From thoth: ssh claude@10.100.0.2, put the key in /var/lib/tailscale-authkey, then on thoth:
#      sudo systemctl restart microvm@claudebox
# 3. GitHub token: github.com/settings/personal-access-tokens/new (fine-grained)
#    Repository access: All repositories. Permissions: Contents read/write, Pull requests read/write. Nothing else.
#    In the VM: gh auth login --with-token, then paste the token.
# 4. In the VM: claude /login
#
# Use: ssh claudebox, tmux, claude --dangerously-skip-permissions
{
  config,
  lib,
  pkgs,
  ...
}:
let
  tap = "vm-claude";
  dns = config.var.homelab.pihole;
  # New connections the guest must not open, dropped in mangle (after conntrack, before Docker's DNAT) so replies to host-initiated SSH still pass.
  blocked = [
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "100.64.0.0/10"
    "169.254.0.0/16"
  ];
  # -I prepends, so the DNS accepts (inserted last) end up above the drops.
  specs =
    map (range: "-d ${range} -j DROP") blocked
    ++ map (protocol: "-d ${dns} -p ${protocol} --dport 53 -j ACCEPT") [
      "udp"
      "tcp"
    ];
  rules =
    flag:
    lib.concatMapStringsSep "\n" (
      spec:
      "iptables -t mangle ${flag} PREROUTING -i ${tap} -m conntrack --ctstate NEW ${spec} 2>/dev/null || true"
    ) specs;

  # Backs up the CLAUDE.md git rules below; Claude has root in the guest, so it's a guard against accidents only.
  prePush = pkgs.writeShellScript "pre-push" ''
    zero=0000000000000000000000000000000000000000
    while read -r localRef localSha remoteRef remoteSha; do
      case "$remoteRef" in
        refs/heads/main | refs/heads/master)
          echo "claudebox: no direct pushes to $remoteRef, open a PR" >&2
          exit 1
          ;;
      esac
      if [ "$localSha" = "$zero" ]; then
        echo "claudebox: deleting remote branches is not allowed" >&2
        exit 1
      fi
      if [ "$remoteSha" != "$zero" ] && ! git merge-base --is-ancestor "$remoteSha" "$localSha"; then
        echo "claudebox: non-fast-forward push to $remoteRef rejected" >&2
        exit 1
      fi
    done
  '';
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
        # The guest root is ephemeral; this keeps tailscale's identity and the SSH host key across reboots.
        {
          image = "var-lib.img";
          mountPoint = "/var/lib";
          size = 10240;
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
        dns = [ dns ];
      };
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      hostKeys = [
        {
          path = "/var/lib/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
    # Inbound only: the tailnet policy gives tag:claudebox no outbound grants, so other nodes drop its traffic.
    # Tailscale SSH authenticates by tailnet identity, so other devices need no keys in here.
    services.tailscale = {
      enable = true;
      authKeyFile = "/var/lib/tailscale-authkey";
      extraUpFlags = [
        "--ssh"
        "--advertise-tags=tag:claudebox"
        "--accept-dns=false"
      ];
    };

    environment.etc."claude-code/CLAUDE.md".text = ''
      # claudebox

      You are running in an isolated VM built for long, autonomous dev work. You have full root here.
      The VM can reach the internet but not the owner's LAN or tailnet, so don't try.

      ## Git and GitHub rules

      These are hard rules. A pre-push hook backs them up, but don't rely on it and never bypass it (no `--no-verify`, no editing `core.hooksPath`).

      - Never push to `main` or `master`. Do all work on a new branch named for the task.
      - Always raise a pull request with `gh pr create` for new work. Never merge your own PRs; the owner reviews and merges.
      - Never force push (`--force`, `--force-with-lease`, `+refspec`).
      - Never rewrite published history: no `rebase`, `commit --amend`, `reset`, or `filter-branch` on commits that were pushed.
      - Never delete remote branches, tags, or repositories.
      - If a task seems to need any of the above, stop and say so in the PR or your final message instead.
    '';
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
    programs.git = {
      enable = true;
      config = {
        credential."https://github.com".helper = "!gh auth git-credential";
        user.name = "Claude (claudebox)";
        user.email = "shaunakdpandit@gmail.com";
        core.hooksPath = "/etc/git-hooks";
      };
    };
    environment.etc."git-hooks/pre-push".source = prePush;

    environment.systemPackages = with pkgs; [
      claude-code
      dig
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
