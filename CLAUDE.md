# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A NixOS flake (nixos-unstable + home-manager) that defines four machines. The repo is expected to be cloned at `~/dev/nixus`, and some things depend on that absolute path (the rebuild command, wallpaper paths in the mango autostart). The repo is source controlled, so **never write secrets into it.**

| Host    | User   | Role                                                                                           |
|---------|--------|------------------------------------------------------------------------------------------------|
| `t14`   | `void` | ThinkPad T14 AMD laptop: CachyOS kernel, mango WM, gaming                                      |
| `d4080` | `void` | Desktop with NVIDIA: CachyOS kernel, mango WM, gaming, Star Citizen                            |
| `thoth` | `hugh` | Headless home server: legacy NVIDIA, Docker/OCI containers, tailscale, claudebox microVM      |
| `rama`  | `icarus` | Headless home server (Dell Precision 5810, Quadro M2000, 16GB): pihole, unbound, glance agent, nixarr, ZFS, samba |

Planned: a work laptop (t14 plus work tooling) and macOS hosts running home-manager (via nix-darwin or standalone). Keep that in mind when deciding where something belongs (see "Profiles").

## The Nix way: everything is declarative

This is the most important rule in this repo. **Every change must be expressed in Nix (or in a file Nix manages). Do not suggest or rely on imperative, one-off shell commands to configure, install, or fix anything.**

- Packages come from `environment.systemPackages`, `home.packages`, or a module's own `package`/`extraPackages` option. Never suggest `nix-env -i`, `nix profile install`, `pip install`, `npm install -g`, `cargo install`, `go install`, `brew`, or downloading binaries by hand.
- Configuration files are managed by NixOS or home-manager modules (`programs.*`, `services.*`, `xdg.configFile`, `home.file`, `environment.etc`). Never tell the user to edit files in `~`, `~/.config`, or `/etc` by hand. They are either generated or read-only symlinks into the Nix store.
- Services, users, groups, firewall rules, kernel params, sysctls, and mounts go through the matching NixOS options. Never suggest `systemctl enable`, `useradd`, `iptables`, `sysctl -w`, `modprobe`, or `chmod`/`chown` fixes. Use `systemd.tmpfiles`, `users.users`, `networking.firewall`, `boot.kernel.sysctl`, and so on.
- Containers are `virtualisation.oci-containers` definitions in `containers/`. Never suggest `docker run` or `docker compose up`.
- Dev tooling and one-off dependencies belong in a module, a `devShell` in the flake, or `packages/`. Don't use ad hoc `nix-shell -p` or `nix run` as a fix.
- If something is hard to express declaratively, look for an existing module option, then an overlay or override, then a small custom derivation in `packages/`, and only then ask the user. Don't fall back to a shell workaround.
- Prefer existing NixOS/home-manager options over raw config strings or `extraConfig` blobs. Use `lib.mkIf`, `lib.mkDefault`, `lib.mkForce`, and `lib.mkOption` deliberately. Use `mkDefault` in shared modules so hosts can override.
- Pin and reproduce. Don't fetch from the network at runtime, and use `fetchFromGitHub`/`fetchurl` with hashes for anything custom.
- The only commands appropriate to mention are the standard flake workflow in "Commands" below, and they are for the *user* to run.

## Environment constraints for Claude

- The Claude Code config in `home/shell/claudeCode.nix` allows a fixed set of read-only, eval, and build commands: `nix flake check/show/metadata/prefetch`, `nix eval`, `nix build`, `nix search`, `nix path-info`, `nix why-depends`, `nix derivation show`, `nix log`, `nix hash`, `nix store prefetch-file`, `nix-prefetch-url`, `nix-instantiate`, `nixos-option`, `nixfmt`, and `nixpkgs-fmt`. Any other command prompts the user for approval, except a deny list that is always refused: `nixos-rebuild`, `home-manager`, `sudo`, `nix flake update/lock`, `nix run/shell/develop`, garbage collection, and git commands that change state (only read-only git is allowed). `WebFetch`, `Agent`, and `Task` are denied.
- Use these commands to verify your edits:
  - Format edited files with `nixfmt <file>`.
  - Check that every host evaluates with `nix flake check`, or check a single host cheaply with `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.
  - Look up packages with `nix search nixpkgs <name>` and options with `nix eval .#nixosConfigurations.<host>.options.<path>.description` (or `.default`, `.type.description`). For home-manager options, use `...config.home-manager.users.<user>.<path>` for values.
  - Use `nix build --no-link` only when evaluation isn't enough. Always pass `--no-link` so no `result` symlink lands in the repo.
- Flakes only see git-tracked files, and you can't run `git add`. New files are invisible to `nix flake check` until the user stages them, so say so instead of reporting a false failure.
- If the Bash sandbox blocks nix (`cannot create Unix domain socket`, or a locked `.gitmodules`), evaluate a copy instead:
  1. Copy the tracked and untracked regular files (`git ls-files -co --exclude-standard`) into `$TMPDIR/repo`. Skip the character-device placeholders the sandbox puts over dotfiles.
  2. Run `nix eval` with `--extra-experimental-features read-only-local-store --store "local?root=$TMPDIR/store" --option substituters "local?read-only=true" --option require-sigs false --no-write-lock-file path:$TMPDIR/repo#...` and set `XDG_CACHE_HOME=$TMPDIR/cache`.

  This also lets new, unstaged files evaluate. The desktop hosts fetch a few sources over the network, so allow `gitlab.com`, `github.com`, and `api.github.com`.
- Never activate anything. After editing, list exactly which files changed, which hosts they affect, and what you verified, then ask the user to run the rebuild.
- Claude Code settings are generated by Nix. `~/.claude/settings.json` is a read-only store symlink, so make changes in `home/shell/claudeCode.nix`. The OpenRouter API key is read at runtime from `~/.config/openrouter/api_key` by a wrapper script, and it must never be put in any `.nix` file.

## Commands

For the user to run. Claude may run the check/build ones, never the switch:

```sh
sudo nixos-rebuild switch --flake ~/dev/nixus#<host>   # apply (the `rb` alias does this for the current host)
nixos-rebuild build --flake .#<host>                   # build without activating
nix flake check                                        # evaluate all hosts
nix flake update [input]                               # bump flake.lock
# formatting: nixfmt-rs and nixpkgs-fmt come from nvim extraPackages (formatting runs through conform.nvim)
```

There are no tests. The only correctness check is that every host still evaluates and builds (`nix flake check`). A shared module can break a host that isn't the one you're on, so consider every host when editing anything under `system/`, `home/`, or `containers/`.

Flakes only see files that git tracks, so a new `.nix` file or dotfile has to be `git add`ed before a rebuild will find it. Remind the user of this whenever you create a file.

Make the edits, format and evaluate them, then ask the user to run the rebuild.

## Do not touch

- `hardware-configuration.nix`: generated per machine.
- `system.stateVersion` / `home.stateVersion`: never change these.
- `flake.lock`: never edit by hand. The user bumps it with `nix flake update`.
- Don't add new flake inputs without asking. Use `inputs.<x>.inputs.nixpkgs.follows = "nixpkgs"` where appropriate to avoid duplicate nixpkgs copies.

## Secrets

- Everything evaluated ends up world-readable in `/nix/store`. No API keys, passwords, tokens, or private keys in any `.nix` file or in `dots/`.
- Secrets are read at runtime from files outside the repo (e.g. `~/.config/openrouter/api_key`), or provided through a secrets module if one is adopted later (sops-nix / agenix).
- Reference secret *paths*, never secret *values*.

## Layout and how modules compose

The structure has three layers. Each layer only imports from the one below it:

```
hosts/<host>/        what this machine is: picks one profile + extra features, sets machine-only values
system|home/profiles/  feature sets: the shared baseline for a kind of machine
system/ home/ containers/   features: one service or tool per file
```

```
flake.nix                 inputs + mkHost; one line per host
homelab.nix               LAN IPs, exposed as config.var.homelab.<name>
hosts/<host>/
  configuration.nix       NixOS: imports a system profile + extras
  home.nix                home-manager: imports a home profile + extras
  variables.nix           per-host values (config.var.*)
  hardware-configuration.nix
system/profiles/          base.nix, desktop.nix, server.nix
home/profiles/            base.nix, desktop.nix
system/  home/  containers/  packages/  dots/  walls/
```

### flake.nix
- `mkHost "<name>"` builds `nixosConfigurations.<name>` from `hosts/<name>/configuration.nix`, adds home-manager, and points `home-manager.users.${config.var.username}` at `hosts/<name>/home.nix`.
- `inputs` reaches every NixOS and home-manager module through `specialArgs` / `extraSpecialArgs`.
- The flake doesn't know which host uses which feature. Keep it that way: no per-host module lists here.

### Profiles
Profiles are plain files: an `imports` list plus the settings every machine of that kind shares. A host imports exactly one system profile and one home profile. Each profile imports the one below it.

| Profile | Imports / sets | Used by |
|---|---|---|
| `system/profiles/base.nix` | stylix (+ its flake module), optimization, boot, locale, utils; hostname from `var.hostname`; networkmanager, printing, flakes, allowUnfree; zsh; the user account from `var.username` (`wheel`, `networkmanager`); the shared CLI package list; `var.homelab` | every NixOS host (via the two below) |
| `system/profiles/desktop.nix` | base + audio, mango, peripherals, the helium NixOS module; dolphin, plexamp, wev | t14, d4080 |
| `system/profiles/server.nix` | base + fail2ban, tailscale, virtualisation; `docker` group; all terminfo; docker-compose, compose2nix | thoth, rama |
| `home/profiles/base.nix` | shell, utils, dev, nvim, mytools; `EDITOR`/`TERMINAL`; `var.homelab` | every host |
| `home/profiles/desktop.nix` | home base + mango, ghostty, librewolf, waybar, fuzzel, feh, sioyek, easyeffects, iptvnator, idleSuspend, cliamp, newsboat, claudeCodeNative | t14, d4080 |

- `home/profiles/base.nix` must stay portable (no wayland, systemd user services, or Linux-only packages), because macOS hosts will import it. Linux desktop things go in `home/profiles/desktop.nix` or a feature file. `home/shell/shell.nix` still has a few Linux-only aliases (fuzzel, cliphist) that will need to move out before a macOS host arrives.
- Something that only some machines of a kind want stays a feature, imported by those hosts. Examples: gaming, cachyos, nvidia, laptop, claudeCodeNative on thoth.
- Lists like `users.users.<user>.extraGroups`, `packages`, and `environment.systemPackages` merge, so a host or feature adds to them and doesn't redefine them. For example, d4080 adds `input`, and server.nix adds `docker`.
- Add a new profile only when a second machine of a new kind appears. Until then, put things in the host.

### Features
- `system/` holds NixOS modules, `home/` holds home-manager modules, and `containers/` holds OCI containers. Each file is one service or tool. A folder with a `default.nix` groups related files (`system/gaming/`, `home/mango/`, `home/mytools/`). Turn a feature on by importing it. Don't add enable-flags or conditionals in shared modules.
- **A feature brings its own flake module.** If a feature needs an external flake's module, the feature file imports it: `system/mango.nix` imports `inputs.mangowm.nixosModules.mango`, and `home/mango/default.nix` imports `inputs.mangowm.hmModules.mango`. The same goes for `system/sops.nix` (sops-nix), `home/helium.nix`, `system/claudebox.nix` (microvm), `system/nixarr.nix` (nixarr), and `system/cachyos.nix` (kernel overlay and binary cache). A hardware module that applies to one machine, like nixos-hardware's t14 module, goes in that host's `configuration.nix`. Importing the feature is then enough, and `flake.nix` never changes.
- `system/gaming/default.nix` aggregates drivers, steam, and runelite. `performance.nix` and `starcitizen.nix` are imported separately, only on d4080.
- `containers/` holds OCI container definitions (`virtualisation.oci-containers`) for thoth and rama. `grimmory.nix` and some others were generated by `compose2nix` from docker-compose files. When you add a container, also open its ports in `networking.firewall` in the hosting server's `configuration.nix`.

### Hosts
- `hosts/<host>/` is the only place hosts differ. It holds only what's genuinely specific to that machine: the profile and extra feature imports, the kernel, firewall ports, ssh keys, secrets, and `stateVersion`. If two hosts would carry the same lines, move them into a profile or feature.
- `variables.nix` declares a free-form `options.var` attrset and sets per-host values: `hostname`, `username`, `remap`, `rebuildCommand`, and on t14 `suspendOnBatteryOnly`. Both `configuration.nix` and `home.nix` import it, so `config.var.*` works in NixOS and home-manager modules alike. For example, `home/shell/shell.nix` uses `config.var.rebuildCommand` and `home/mango/default.nix` uses `config.var.remap`. Put new per-host values here.
- `home.username` and `home.homeDirectory` aren't set anywhere. home-manager's NixOS module derives them from `users.users`, and nix-darwin's does the same.
- `homelab.nix` is the one list of LAN addresses. Both base profiles set `var.homelab` from it (`var` is `types.attrs`, so it shallow-merges with `variables.nix`). Use `config.var.homelab.<name>` and never hardcode a `192.168.4.x`. `system/tailscale.nix` advertises `homelab.<hostname>`, so a server must have its own entry there.

### Adding things
- **A NixOS host**: copy the closest sibling directory (t14 for a laptop, rama for a server), then:
  1. Put in the new `hardware-configuration.nix`.
  2. Set `hostname`/`username`/`rebuildCommand` in `variables.nix`.
  3. Trim the extra imports and the machine-specific settings (secrets, remote builder, firewall).
  4. Add `<name> = mkHost "<name>";` to `flake.nix`.
  5. Add an IP to `homelab.nix` if it's on the LAN.
  6. Keep the new install's `stateVersion`.
- **A work laptop**: copy `hosts/t14`, drop its sops and remote-builder sections, and add work-only modules (e.g. a `home/work/` folder) to its import lists.
- **A macOS host (not built yet)**: add a `mkDarwin` beside `mkHost` that reuses the same home-manager settings. Its `home.nix` imports `home/profiles/base.nix` plus mac-only modules.
- **A feature**: create one file in `system/`, `home/`, or `containers/`. Import it from the profile if every machine of that kind wants it, otherwise from each host that does. If it needs a new flake input, ask first, then import the input's module inside the feature file.

### Other directories
- `dots/` holds raw config files that home-manager links into `~/.config` via `xdg.configFile` (nvim, tmux, cliamp). `dots/ghostty` isn't used, because ghostty is configured in `home/ghostty.nix`. Since these files are copied into the Nix store, editing them takes a rebuild.
- `packages/` holds custom derivations. `plexamp-tui.nix` isn't imported anywhere right now.
- `walls/` holds wallpapers, used by stylix (`system/stylix.nix`) and swaybg (mango autostart).

## Conventions

- Put shared behavior in `system/`, `home/`, or `containers/`, and shared baselines in `system/profiles/` or `home/profiles/`. Host directories contain only what is genuinely specific to that machine.
- Prefer readable over clever: explicit import lists, plain attrsets, and no generated module lists or custom option frameworks. Someone new to Nix should be able to follow a host from `flake.nix` down to a feature file.
- Format with `nixfmt-rs` / `nixpkgs-fmt` (see Commands) and match the style of the surrounding file.
- Keep code concise and simple to read. Prefer the shortest clear expression, and avoid needless abstraction, indirection, or boilerplate.
- Don't over-comment. Comment the *why*, not the *what*, especially for workarounds, and leave self-explanatory code uncommented.

## Home Server configuration
- Home server is comprised of 3 servers:
    - thoth (192.168.4.28) as the main compute running the defined contianers
    - an ubuntu based raspberry pi 4b 2Gb running traefik as reverse proxy
    - a dietpi based raspberry pi 4b 2GB running pihole and unbound as well as tailscale
        - tailscale is globally configured to use this pi with unbound as the dns and also sends tailnet trafic through the pihole configuration
- rama (192.168.4.29) is being onboarded to replace both pis. It runs pihole, unbound, and a glance agent as containers; traefik isn't configured yet.
- All LAN addresses live in `homelab.nix`.
- Home server configuration is accessible to outside network via cloudflare on domain jssp.io. webui and booklore are CNAMED to jssp.io, traefik reverse proxy handles routing for these services

## Theming

Stylix (`system/stylix.nix`) is the source of truth for colors, fonts, and the cursor. The current scheme is base16 `black-metal-immortal`. Home modules read the palette with `config.lib.stylix.colors` (`c.base0B` etc., or `.withHashtag`) instead of hardcoding hex, as in the mango border colors, waybar, fuzzel, and firefox. Some theme pieces can't come from stylix and are marked with a `THEME_UPDATE` comment: the nvim colorscheme in `dots/nvim/lua/plugins/init.lua` and the ghostty palette override. When you change the scheme, grep for `THEME_UPDATE` and update each marked spot.

## Neovim

The config lives in `dots/nvim` and uses Neovim's built-in `vim.pack` and `vim.lsp.enable`, not lazy.nvim or lspconfig. `dots/nvim/lsp/*.lua` are vendored server configs, and `lua/lsp.lua` lists which ones are enabled. Language servers and formatters come from Nix (`programs.neovim.extraPackages` in `home/shell/nvim.nix`), not mason. To enable a new LSP, add the package there and add the name to `lua/lsp.lua`. `nvim-pack-lock.json` is filtered out of the store copy.
