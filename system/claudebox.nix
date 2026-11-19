# Isolated microVM where Claude runs with full permissions: internet plus home DNS only, no LAN/tailnet/host services.
#
# One-time setup:
# 1. Tailnet policy (login.tailscale.com > Access controls). Edit, don't replace the file:
#      add     "tagOwners": { "tag:claudebox": ["autogroup:admin"] },
#      change  the allow-all grant's "src": ["*"] to "src": ["autogroup:member"]
#      append  to "ssh": { "action": "accept", "src": ["autogroup:member"], "dst": ["tag:claudebox"], "users": ["claude"] }
#    Tagged nodes aren't members, so claudebox can't reach out. Other tagged nodes need their own grants.
#    Make sure no "autoApprovers" entry matches tag:claudebox, and never approve routes or exit nodes it advertises.
#    add tests, so the console rejects any later policy edit that lets claudebox out
#    (thoth, rama, dietpi, iphone171, and thoth's 192.168.4.28/32 subnet route; add new devices here as they join):
#      "tests": [
#        { "src": "tag:claudebox", "deny": [
#            "100.67.36.10:22", "100.67.36.10:3000", "192.168.4.28:22",
#            "100.94.125.114:22", "100.102.220.56:22", "100.102.220.56:53", "100.116.199.110:443" ] },
#        { "src": "cfdyg4mhtp@privaterelay.appleid.com", "accept": [ "tag:claudebox:22" ] }
#      ],
#      "sshTests": [
#        { "src": "cfdyg4mhtp@privaterelay.appleid.com", "dst": [ "tag:claudebox" ], "accept": [ "claude" ], "deny": [ "root" ] }
#      ]
# 2. Auth key: Settings > Keys > Generate auth key, with tag:claudebox and not reusable.
#    From thoth: ssh claude@10.100.0.2, put the key in /var/lib/tailscale-authkey, then on thoth:
#      sudo systemctl restart microvm@claudebox
# 3. GitHub token: github.com/settings/personal-access-tokens/new (fine-grained)
#    Repository access: All repositories. Permissions: Contents read/write, Pull requests read/write, Issues read/write. Nothing else.
#    In the VM:
#       1. gh auth login --with-token
#       2. paste token and hit enter
#       3. ctrl+d
# 4. In the VM: claude /login
#
# Use: ssh claudebox, tmux, claude (aliased to --dangerously-skip-permissions)
#
# Persistence: the guest root is rebuilt from this file on every boot. Images in /var/lib/microvms/claudebox/ on thoth keep:
#   home.img     /home: repos, ~/.claude (login, sessions), ~/.config/gh (token)
#   nix-rw.img   /nix/.rw-store: store paths built or fetched inside the VM
#   var-lib.img  /var/lib: tailscale identity and auth key, SSH host key
# ~/shared lives on thoth (/var/lib/claudebox/shared) and survives a reset.
#
# Reset (on thoth): sudo systemctl stop microvm@claudebox, delete the images to wipe, sudo systemctl start microvm@claudebox.
#   Empty images are recreated at boot. Deleting only nix-rw.img keeps all logins; only home.img needs steps 3-4 again.
#   After deleting var-lib.img: remove the old claudebox node in the tailscale console (or it rejoins as claudebox-1),
#   redo steps 2-4, and drop the stale claudebox / 10.100.0.2 entries from known_hosts.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  tap = "vm-claude";
  # Host side of the VM's ~/shared, owned by the host user (uid 1000 on both sides).
  shared = "/home/${config.var.username}/claudebox";
  dns = config.var.homelab.pihole;
  # Guest traffic other than replies, dropped in mangle (after conntrack, before Docker's DNAT) so replies to host-initiated SSH still pass.
  # Matching everything but ESTABLISHED,RELATED also catches INVALID packets, which a NEW-only match would let through.
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
  # Only deletes may fail (rule absent); a failed insert must fail the firewall unit instead of silently leaving the guest unisolated.
  rules =
    flag:
    lib.concatMapStringsSep "\n"
      (command: command + lib.optionalString (flag == "-D") " 2>/dev/null || true")
      (
        map (
          spec:
          "iptables -t mangle ${flag} PREROUTING -i ${tap} -m conntrack ! --ctstate ESTABLISHED,RELATED ${spec}"
        ) specs
        # The guest has root and can re-enable IPv6; tailscale turns on host IPv6 forwarding, and link-local would reach host ports.
        ++ [ "ip6tables -t raw ${flag} PREROUTING -i ${tap} -j DROP" ]
      );

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
  imports = [ inputs.microvm.nixosModules.host ];

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
      shares = [
        {
          proto = "virtiofs";
          tag = "shared";
          source = shared;
          mountPoint = "/home/claude/shared";
        }
      ];
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

    environment.shellAliases.claude = "claude --dangerously-skip-permissions";
    # Ponytail plugin, status line and effort shared with the hosts.
    # Stylix themes nvim (and auto-imports its home-manager module for the user below).
    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      ./stylix.nix
    ];
    home-manager = {
      useGlobalPkgs = true;
      # /home persists, so files Claude or tools created there must not block activation.
      backupFileExtension = "hm-backup";
      users.claude = {
        imports = [
          ../home/shell/claudeCodeBase.nix
          ../home/shell/tmux.nix
          ../home/shell/nvim.nix
        ];
        # Lets home.shellAliases (tm, tmm, tmn) reach the login shell.
        programs.bash.enable = true;
        # Claude owns ~/.claude here and writes settings.json itself, which blocks a read-only symlink; merge into it instead.
        programs.claude-code.mutableSettings = true;
        # Teaches Claude the agent-browser CLI (ships with the package).
        programs.claude-code.skills.agent-browser = "${pkgs.agent-browser}/skills/agent-browser";
        home.stateVersion = "26.05";
      };
    };
    # Use nixpkgs' chromium instead of agent-browser downloading its own.
    environment.variables.AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
    environment.etc."claude-code/CLAUDE.md".text = ''
      # claudebox

      You are running in an isolated VM built for long, autonomous dev work. You have full root here.
      The VM can reach the internet but not the owner's LAN or tailnet, so don't try.

      ## Shared directory

      `~/shared` (`/home/claude/shared`) is shared live with the owner's host machine. Use it to hand over
      notes, reports and other markdown, and to read files the owner drops in for you. The owner reads everything
      written here, so never put secrets or tokens in it. Keep repos and build output out of it, in `~` instead.

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
      # Matches the host user so files in ~/shared are owned correctly on both sides.
      uid = 1000;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmL0OiFEZ/l2usxzvKkje514gDkfUg6JpArW7CoguxX shaunakdpandit@gmail.com"
        # void@t14
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOST1BDY81RViIwoRqex1mYipRpRdDf3fwBgUAYmusVS shaunakdpandit@gmail.com"
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
      fzf
      fd
      jq
      curl
      tmux
      # Lets ssh sessions from ghostty (TERM=xterm-ghostty) work with clear, nvim and tmux.
      ghostty.terminfo
      nodejs
      python3
      gcc

      # Headless browser
      agent-browser
      chromium

      # Go
      go
      gopls
      golangci-lint
      delve

      # JavaScript / TypeScript
      typescript
      typescript-language-server
      pnpm
      bun

      # OSINT
      whois
      theharvester
      amass
      subfinder
      dnsx
      dnsrecon
      sherlock
      maigret
      holehe
      exiftool
      waybackurls
      gau

      # Active scanning: targets and the ISP see the home IP, so these stay off until
      # the VM's traffic is routed through a VPN on thoth (e.g. Proton WireGuard, policy-routed for 10.100.0.0/24).
      # nmap
      # naabu
      # httpx
      # katana
      # nuclei
      # ffuf
      # gobuster
      # nikto
      # whatweb
      # wafw00f
      # testssl
      # sqlmap
      # hydra

      # Security (offline / local)
      john
      trufflehog
      gitleaks
      # shortcut: upstream test_emudhra fails against nixpkgs' current CA bundle; drop the override once nixpkgs fixes it.
      (mitmproxy.overridePythonAttrs { doCheck = false; })
      tcpdump
      socat
      binwalk
      radare2
      yara
      seclists
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

  # The guest has root and virtiofsd runs as root, so it could plant setuid or device files; this mount
  # neuters them on the host. The backing directory is root-only so the share is reachable only through it.
  systemd.tmpfiles.rules = [
    "d /var/lib/claudebox 0700 root root -"
    "d /var/lib/claudebox/shared 0755 ${config.var.username} users -"
    "d ${shared} 0755 ${config.var.username} users -"
  ];
  fileSystems.${shared} = {
    device = "/var/lib/claudebox/shared";
    fsType = "none";
    options = [
      "bind"
      "nosuid"
      "nodev"
      "noexec"
    ];
  };
  systemd.services."microvm-virtiofsd@claudebox".unitConfig.RequiresMountsFor = [ shared ];
  networking.nat = {
    enable = true;
    internalInterfaces = [ tap ];
    externalInterface = "enp5s0";
  };
  # Delete first so firewall reloads do not stack duplicate rules.
  networking.firewall.extraCommands = rules "-D" + "\n" + rules "-I";
  networking.firewall.extraStopCommands = rules "-D";
}
