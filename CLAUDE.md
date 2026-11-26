# CLAUDE.md

A NixOS flake (nixos-unstable + home-manager) for five machines. The repo lives at `~/dev/nixus` (the rebuild alias and wallpaper paths depend on it) and is public, so **never write secrets into it.** The goal is a repo a human reads easily, where adding a host is a few lines.

| Host    | User      | Role                                                                     |
|---------|-----------|--------------------------------------------------------------------------|
| `t14`   | `void`    | ThinkPad T14 AMD laptop: CachyOS kernel, mango WM, gaming, sops          |
| `d4080` | `void`    | NVIDIA desktop: CachyOS kernel, mango WM, gaming, Star Citizen           |
| `thea`  | `shaunak` | Work laptop: desktop plus work tools                                     |
| `thoth` | `hugh`    | Headless server, legacy NVIDIA: most containers, claudebox microVM       |
| `rama`  | `icarus`  | Headless server: pihole, unbound, glance agent                           |

## Rules and what enforces them

Prefer enforcement over prose: when a mistake happens twice, turn it into a check or assertion whose error names the fix, and add a row here. A rule enforced only by this file is the weakest kind.

| Rule | Enforced by |
|---|---|
| Every host evaluates | `nix flake check` |
| Formatted with nixfmt | `checks.format`, edit hook |
| No anti-patterns or dead code (`_name` for positional args, `# deadnix: skip` for kept alternatives) | `checks.statix`, `checks.deadnix`, edit hook |
| No hardcoded LAN IPs; use `config.var.homelab.<name>` | `checks.repo-rules` |
| No private keys or API keys in the repo | `checks.repo-rules` (patterns only; stay careful) |
| A host directory holds only its four files | `checks.repo-rules` |
| A host running pihole has a DNS fallback outside itself | assertion in `containers/pihole.nix`, `checks.pihole-dns-fallback` |
| A host-network container opens its ports in its own file | assertion in `system/virtualisation.nix` |
| Host values (`config.var.*`) exist and have the right type | option types in `var.nix` |
| No activation, lock bumps, or history rewrites | permission deny list in `home/shell/claudeCodeNative.nix` |
| Everything declarative; no imperative fixes | this file |
| Don't touch `hardware-configuration.nix`, `stateVersion`, or `flake.lock` | this file |
| No new flake inputs without asking | this file |

The edit hook (`home/shell/claudeCodeBase.nix`) formats and lints each `.nix` file Claude writes and hands findings back. Checks live in `checks.nix`.

## Verify before claiming done

1. `nix flake check`: lints, repo rules, regression tests, and every host's evaluation (which runs all module assertions).
2. Prove behavior, not just evaluation: `nix eval` the exact options you changed on every host they affect, and compare against the old values. To see what a change ships, diff the closure against master: `nix store diff-closures "git+file://$PWD?ref=master#nixosConfigurations.<host>.config.system.build.toplevel" ".#nixosConfigurations.<host>.config.system.build.toplevel"` (this builds both, and lists only package version and size changes: a config-only change prints nothing, so the option values from the step above are its proof).
3. **Bug fixes reproduce first.** Rebuild the broken config with `extendModules` and watch it fail. Then add an assertion to the feature file whose message names the fix, plus a `checks.nix` entry proving the assertion fires on the broken config. `checks.pihole-dns-fallback` is the template.
4. New files are invisible to flakes until `git add`ed. Stage them.
5. Never activate. Report the files changed, the hosts affected, and what you verified, then ask the user to run `rb` (`sudo nixos-rebuild switch --flake ~/dev/nixus#<host>`).

Claude's allowed and denied commands are in `home/shell/claudeCodeNative.nix`. Run `nix` commands alone (no pipes or `&&`), or the Bash sandbox blocks the daemon socket. Use `nix build --no-link` so no `result` symlink lands in the repo.

## The Nix way

Every change is expressed in Nix. No `nix-env`, `nix profile`, `pip`/`npm -g`, `systemctl enable`, `docker run`, hand-edited dotfiles, `chmod` fixes, or one-off `nix-shell -p`. Use the matching option: `environment.systemPackages`, `home.packages`, `programs.*`, `services.*`, `xdg.configFile`, `systemd.tmpfiles`, `users.users`, `networking.firewall`, `virtualisation.oci-containers`. If an option is missing, try an override, then a small derivation in `packages/`, then ask. Pin custom sources with hashes. Prefer typed options over `extraConfig` strings, and `lib.mkDefault` in shared modules so hosts can override.

## Layout

Three layers, each importing only the one below:

```
hosts/<host>/           configuration.nix, home.nix, variables.nix, hardware-configuration.nix
system|home/profiles/   base, desktop, server, work: the shared baseline for a kind of machine
system/ home/ containers/   features: one service or tool per file
```

- **Hosts** import exactly one system profile and one home profile, plus extra features, and hold only what is unique to the machine (kernel, firewall ports, ssh keys, secrets, `stateVersion`). Two hosts carrying the same lines means it belongs in a profile or feature.
- **Profiles**: `base` (every host) → `desktop` (t14, d4080) → `work` (thea); `base` → `server` (thoth, rama). `home/profiles/base.nix` must stay portable (no wayland, systemd user services, or Linux-only packages) for future macOS hosts.
- **Features** are switched on by importing them, never by enable-flags. A feature imports its own flake module (`system/mango.nix` imports `inputs.mangowm.nixosModules.mango`), so `flake.nix` never learns which host uses what. A rule a feature depends on lives in that feature as an `assertion`.
- `var.nix` declares the typed `config.var.*` options and their defaults; both base profiles import it. A host's `variables.nix` only sets values (`hostname`, `username`, and any non-defaults) and is imported by both `configuration.nix` and `home.nix`. `homelab.nix` is the one list of LAN addresses, exposed as `config.var.homelab.<name>`; a server needs its own entry (tailscale advertises it).
- Lists such as `extraGroups` and `systemPackages` merge: add to them, don't redefine them.
- `containers/` holds `oci-containers` definitions (some generated by `compose2nix`). `system/virtualisation.nix` restarts them weekly to pull new images. Docker-published ports bypass the NixOS firewall, so don't list them there; a host-network container opens its own ports in its file. `nix eval --raw .#ports.<host>` shows everything a host exposes and which file opened it.
- `dots/` holds raw config files linked by home-manager, `packages/` holds custom derivations, and `walls/` holds wallpapers.

**New host:** follow "First-time setup" in `README.md`. **New feature:** one file in `system/`, `home/`, or `containers/`, imported by the profile if every machine of that kind wants it, else by each host.

## Secrets

Everything evaluated is world-readable in `/nix/store`. Reference secret *paths* only: sops-nix files under `secrets/` (decrypted to `/run/secrets`), or runtime files like `~/.config/openrouter/api_key`.

## Home network

thoth (main compute) and rama (DNS) are on the LAN; addresses are in `homelab.nix`. A Raspberry Pi runs traefik for `jssp.io` (public through Cloudflare), and a DietPi runs the current tailnet pihole and unbound; rama is replacing both Pis. Tailscale DNS points at the pihole.

## Theming and Neovim

Stylix (`system/stylix.nix`, scheme `black-metal-immortal`) owns colors, fonts, and the cursor. Read colors through `config.lib.stylix.colors`. To change the scheme, grep `THEME_UPDATE` for the spots stylix can't reach. Neovim (`dots/nvim`) uses built-in `vim.pack` and `vim.lsp.enable`. To add an LSP, add its package to `programs.neovim.extraPackages` in `home/shell/nvim.nix` and its name to `lua/lsp.lua`.
