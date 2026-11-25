# nixus

A NixOS flake (nixos-unstable + home-manager) for my laptops, desktop and home servers. Everything is declarative: packages, dotfiles, services and containers all live here, and secrets are encrypted with sops-nix. The repo is expected at `~/dev/nixus`.

## Hosts

| Host    | User     | Machine                       | Role                                                                    |
|---------|----------|-------------------------------|-------------------------------------------------------------------------|
| `t14`   | `void`   | ThinkPad T14 AMD              | Laptop: mango WM, CachyOS kernel, gaming, sops, builds offloaded to thoth |
| `d4080` | `void`   | Desktop, RTX 4080             | Desktop: mango WM, CachyOS kernel, gaming, Star Citizen                  |
| `thea`  | `shaunak`| Work laptop                   | Desktop profile plus work tools (Teams, Thunderbird, SharePoint, Intune) |
| `thoth` | `hugh`   | Headless server, legacy NVIDIA | Main homelab: Plex, Open WebUI, Grimmory, Crafty, Glance/Gatus, claudebox VM |
| `rama`  | `icarus` | Dell Precision 5810           | Homelab DNS: Pi-hole, Unbound, Glance agent                              |

LAN addresses for all of them are in `homelab.nix`.

## First-time setup

### Any new machine

1. Install NixOS from the ISO, creating the user you'll set as `username` below.
2. Get git for the bootstrap only (the base profile installs it permanently) and clone:
   ```sh
   nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git
   git clone https://github.com/shaunakpandit/nixus ~/dev/nixus
   ```
3. Copy the closest sibling host: `hosts/t14` for a laptop, `hosts/d4080` for a desktop, `hosts/rama` for a server.
4. In the new `hosts/<name>/`:
   - replace `hardware-configuration.nix` with `/etc/nixos/hardware-configuration.nix`;
   - set `hostname`, `username` and `rebuildCommand` in `variables.nix`;
   - set `system.stateVersion` (and `home.stateVersion`) to the installer's value from `/etc/nixos/configuration.nix`;
   - drop imports and settings that belong to the machine you copied (sops secrets, remote builder, firewall ports, GPU modules).
5. Add `<name> = mkHost "<name>";` to `flake.nix`, and its LAN IP to `homelab.nix`.
6. `git add` the new files (flakes only see tracked files), then:
   ```sh
   sudo nixos-rebuild switch --flake ~/dev/nixus#<name> --extra-experimental-features 'nix-command flakes'
   ```
   From then on, `rb` rebuilds the current host.

### GUI clients (laptop/desktop)

- Import `system/profiles/desktop.nix` and `home/profiles/desktop.nix` (or the `work` pair for a work laptop).
- Add optional features to the host's import lists: `system/gaming`, `system/cachyos.nix`, `system/nvidia.nix`, `system/laptop.nix`, `home/protondrive.nix`, …
- Anything that needs a secret (Proton Drive, remote builder keys, API keys) needs sops on that machine first; see below.

### Servers

- Import `system/profiles/server.nix` and `home/profiles/base.nix`, plus the `containers/*.nix` this server runs.
- The host **must** have an entry in `homelab.nix`: tailscale advertises it as a subnet route.
- Open every container port in the host's `networking.firewall`.
- Add your SSH public key to `users.users.<user>.openssh.authorizedKeys.keys`.
- Join the tailnet after the first switch: `sudo tailscale login` (or put an auth key in `/etc/tailscale/authkey`).

## sops

Secrets live encrypted in `secrets/<host>.yaml`. Each host can only decrypt its own file, and they're decrypted at boot into `/run/secrets` (never the Nix store). `.sops.yaml` lists which age keys can open which file. The `sops`, `age` and `ssh-to-age` tools come from `system/sops.nix` once it's imported; before that, use `nix develop` in the repo.

### Set up a host

1. Generate an age key on the machine (keep a backup; losing it means losing the secrets):
   ```sh
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   age-keygen -y ~/.config/sops/age/keys.txt   # prints the public key, age1...
   ```
   On a server with an SSH host key you can use that instead: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`, and set `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];` in step 4.
2. Add the public key and a rule for the host's file to `.sops.yaml`:
   ```yaml
   keys:
     - &void age1...
     - &d4080 age1...
   creation_rules:
     - path_regex: secrets/d4080\.yaml$
       key_groups:
         - age:
             - *d4080
   ```
3. Create the encrypted file (sops finds the key in `~/.config/sops/age/keys.txt` and opens your `$EDITOR`):
   ```sh
   sops secrets/d4080.yaml
   ```
   Write plain YAML (`name: value`), save and quit; sops writes it back encrypted. Then `git add secrets/d4080.yaml`.
4. In `hosts/<host>/configuration.nix`, import `../../system/sops.nix` and point it at the key:
   ```nix
   sops.age.keyFile = "/home/void/.config/sops/age/keys.txt";
   ```
5. Declare secrets (next section) and rebuild.

### Reinstall a sops host

Building never needs the key: the encrypted files are in git and sops keeps secret names in plain text. Only activation decrypts, using the key file. So on a fresh install:

1. Install NixOS and clone the repo as usual.
2. Restore the backed-up key (one line, e.g. a secure note in Proton Pass) to the path in `sops.age.keyFile`:
   ```sh
   mkdir -p ~/.config/sops/age
   $EDITOR ~/.config/sops/age/keys.txt
   ```
3. Run the first `nixos-rebuild switch`.

If you forget step 2, the switch still activates everything else and reports a secrets error; restore the key and `rb` again. If the key is lost for good, the encrypted file can't be recovered: generate a new key, replace the host's recipient in `.sops.yaml`, and recreate `secrets/<host>.yaml` with fresh values.

### Add a secret

1. `sops secrets/<host>.yaml`, add a line `my_secret: value`, save.
2. Declare it in `hosts/<host>/configuration.nix`:
   ```nix
   sops.secrets.my_secret.owner = config.var.username;   # omit owner for root-only
   ```
3. Use the path, never the value: `config.sops.secrets.my_secret.path` in NixOS modules, `osConfig.sops.secrets.my_secret.path` in home-manager modules. It resolves to `/run/secrets/my_secret` unless you set `path`.

Other commands: `sops updatekeys secrets/<host>.yaml` after changing a file's recipients in `.sops.yaml`; `sops -d secrets/<host>.yaml` to print it decrypted.

---

## Layout

```
flake.nix            inputs and mkHost; one line per host
homelab.nix          LAN IPs, available as config.var.homelab.<name>
hosts/<host>/        picks one profile + extra features; machine-only values (variables.nix)
system/profiles/     base, desktop, server, work  (NixOS)
home/profiles/       base, desktop, work          (home-manager)
system/ home/        one feature per file; importing it turns it on
containers/          OCI containers for the servers
packages/            custom derivations
dots/                raw config files linked into ~/.config (nvim, tmux, cliamp)
walls/               wallpapers
secrets/             sops-encrypted secrets, one file per host
```

A host imports one system profile and one home profile; each profile imports the one below it (`work` → `desktop` → `base`). Features that only some machines want are imported by those hosts directly.

## Profiles

- **system/profiles/base.nix**: stylix theme, boot, locale, store optimisation and weekly GC, NetworkManager, printing, zsh, the user account, shared CLI packages.
- **system/profiles/desktop.nix**: base plus pipewire audio, the mango Wayland compositor, QMK/peripheral udev rules, Helium browser policies, Dolphin, Plexamp.
- **system/profiles/server.nix**: base plus fail2ban, tailscale (subnet router), Docker/OCI with weekly image refresh and the NVIDIA container toolkit, terminfo for SSH, compose2nix.
- **system/profiles/work.nix**: desktop plus Docker, a tailscale client, and Intune.
- **home/profiles/base.nix**: zsh/shell, tmux, Neovim with LSPs and formatters, dev tools, CLI utilities, `mytools`. Kept portable for future macOS hosts.
- **home/profiles/desktop.nix**: mango config, Ghostty, LibreWolf, Waybar, Fuzzel, feh, Sioyek, EasyEffects, IPTVnator, idle/suspend, cliamp, newsboat, Claude Code.
- **home/profiles/work.nix**: desktop plus Discord and `home/work/` (dev tools, Thunderbird, Teams, SharePoint mount, Beekeeper Studio).

## Optional features

| Feature | What it does | Used by |
|---|---|---|
| `system/cachyos.nix` | CachyOS kernels and binary cache | t14, d4080 |
| `system/gaming` | GPU/32-bit drivers, Steam, RuneLite | t14, d4080 |
| `system/gaming/performance.nix` | CachyOS sysctls, zram, ntsync | d4080 |
| `system/gaming/starcitizen.nix` | RSI launcher via nix-citizen, input/cache tweaks | d4080 |
| `system/nvidia.nix` / `nvidiaLegacy.nix` | NVIDIA drivers (current / Pascal-era) | d4080 / thoth, rama |
| `system/laptop.nix` | Power management, backlight | t14, thea |
| `system/sops.nix` | sops-nix, decrypts `secrets/<host>.yaml` | t14 |
| `system/mtp.nix` | MTP device access | thoth |
| `system/claudebox.nix` | microVM where Claude runs isolated (internet + home DNS only); setup steps in the file | thoth |
| `home/protondrive.nix` | Mounts Proton Drive at `~/ProtonDrive` with rclone (needs sops secrets, below) | t14 |
| `home/helium.nix`, `home/discord.nix`, `home/games/*` | Helium browser, Discord (Vencord), Prism Launcher, chess-tui | various |
| `home/nightlight.nix`, `home/idleSuspend.nix`, `home/joystickIdleInhibit.nix` | Waybar night-light toggle, idle suspend (battery-only on laptops), no blanking while a gamepad/HOTAS is in use | various |
| `home/tradingview.nix`, `home/vnc.nix`, `home/dunst.nix` | TradingView, VNC client, notifications | t14, t14, thea |

### Proton Drive

`home/protondrive.nix` configures rclone declaratively and mounts the drive at `~/ProtonDrive`, which shows up in Dolphin. It reads three sops secrets that the host declares:

```yaml
protondrive_username: you@proton.me
protondrive_password: ...
protondrive_otp_secret: ABCDEF...   # the TOTP seed behind your 2FA codes (from Proton Pass or 2FA setup)
```

rclone generates the 2FA code from the seed. The config is rewritten at every login, so don't add rclone remotes by hand on that machine. To add it to another host: set up sops there, add the three secrets and their `sops.secrets.protondrive_*.owner` lines (copy from `hosts/t14/configuration.nix`), and import `home/protondrive.nix`.

## Homelab

thoth is the main server; rama is replacing the two Raspberry Pis (Pi-hole/Unbound and Traefik). Services are exposed publicly through Cloudflare on `jssp.io`, routed by Traefik.

| Container | Host | Port | Notes |
|---|---|---|---|
| Open WebUI | thoth | 3000 | |
| Plex | thoth | 32400 | also reachable over tailscale |
| Grimmory | thoth | 6060 | generated by compose2nix |
| Crafty Controller | thoth | 8443 | Minecraft servers on 25500–25600, Bedrock 19132 |
| Glance / Gatus | thoth | 8080 / 8081 | dashboard and status checks (`containers/monitoring.nix`) |
| Portainer | thoth | 9443 | currently disabled |
| Pi-hole | rama | 8089 | blocklists declared in `containers/pihole.nix` |
| Unbound | rama | 5335 | recursive resolver behind Pi-hole |
| Glance agent | rama | 27973 | stats for thoth's Glance |

To add a container: create `containers/<name>.nix` (`virtualisation.oci-containers`), import it in the server's `configuration.nix`, open its ports there, and add it to `containers/monitoring.nix` if it should appear on the dashboard. t14 uses thoth as a remote Nix builder.

## Theming

Stylix (`system/stylix.nix`) sets colors, fonts and the cursor for everything; home modules read `config.lib.stylix.colors` instead of hardcoding hex. The few places stylix can't reach are marked `THEME_UPDATE`.

## Neovim

Config is in `dots/nvim`, using Neovim's built-in `vim.pack` and `vim.lsp.enable`. Language servers and formatters come from Nix (`home/shell/nvim.nix`); to add an LSP, add its package there and its name to `dots/nvim/lua/lsp.lua`.

## Commands

```sh
rb                                        # switch the current host
nixos-rebuild build --flake .#<host>      # build without activating
nix flake check                           # evaluate every host
nix flake update [input]                  # bump flake.lock
```
