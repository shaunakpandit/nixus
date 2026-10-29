{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Lives outside the repo; never enters git or the Nix store.
  keyFile = "${config.home.homeDirectory}/.config/openrouter/api_key";

  opus = "anthropic/claude-opus-5.5";
  sonnet = "anthropic/claude-sonnet-5.5";
  haiku = "anthropic/claude-haiku-5.5";

  # Relative to $HOME, hidden inside the jail when they exist: credentials,
  # agent sockets, and browser profiles (cookies are as good as passwords).
  hidden = [
    ".config/openrouter"
    ".ssh"
    ".gnupg"
    ".password-store"
    ".local/share/keyrings"
    ".config/gh"
    ".git-credentials"
    ".netrc"
    ".docker"
    ".mozilla"
    ".librewolf"
    ".config/net.imput.helium"
  ];

  # Claude runs in auto mode, so the whole process (not just its Bash tool)
  # is jailed. The root filesystem is read-only, and only the project,
  # Claude's own state, and the nix eval cache are writable. Builds still go
  # through nix-daemon, whose socket is reachable through the read-only bind.
  # bwrap sets no_new_privs, so sudo and other setuid wrappers can't escalate.
  # The network is shared because the API calls need it.
  # There's no pid namespace and no private /proc, because they stop Claude's
  # own nested bwrap sandbox from mounting /proc.
  jail = pkgs.writeShellScript "claude-jail" ''
    set -euo pipefail

    # Read the key before entering the jail, where its directory is hidden.
    ANTHROPIC_AUTH_TOKEN="$(cat ${keyFile})"
    export ANTHROPIC_AUTH_TOKEN

    # The formatters otherwise only exist on nvim's PATH (extraPackages),
    # so expose them to Claude's shell too. ripgrep is pinned here because
    # this Claude Code build has no Grep/Glob tools and searches via Bash.
    export PATH=${
      lib.makeBinPath [
        pkgs.nixfmt-rs
        pkgs.nixpkgs-fmt
        pkgs.ripgrep
      ]
    }:$PATH

    # Keep Claude's global config in ~/.claude/.claude.json instead of
    # ~/.claude.json, because home is read-only inside the jail. The copy
    # carries over onboarding and trust state on the first run.
    export CLAUDE_CONFIG_DIR="$HOME/.claude"
    mkdir -p "$CLAUDE_CONFIG_DIR" "$HOME/.cache/nix" "$HOME/.cache/claude-cli-nodejs"
    if [ ! -e "$CLAUDE_CONFIG_DIR/.claude.json" ] && [ -e "$HOME/.claude.json" ]; then
      cp "$HOME/.claude.json" "$CLAUDE_CONFIG_DIR/.claude.json"
    fi

    args=(
      --ro-bind / /
      --dev /dev
      --tmpfs /tmp
      --unshare-ipc
      --die-with-parent
      --bind "$CLAUDE_CONFIG_DIR" "$CLAUDE_CONFIG_DIR"
      --bind "$HOME/.cache/nix" "$HOME/.cache/nix"
      --bind "$HOME/.cache/claude-cli-nodejs" "$HOME/.cache/claude-cli-nodejs"
      --unsetenv SSH_AUTH_SOCK
      --unsetenv GPG_AGENT_INFO
      --unsetenv DBUS_SESSION_BUS_ADDRESS
      --unsetenv WAYLAND_DISPLAY
      --unsetenv DISPLAY
    )

    # The project is the only writable part of home. Started from home
    # itself (or /), Claude can read but write nothing outside ~/.claude.
    project="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)"
    if [ "$project" != "$HOME" ] && [ "$project" != / ]; then
      args+=(--bind "$project" "$project")
    fi

    for p in ${lib.escapeShellArgs hidden}; do
      p="$HOME/$p"
      if [ -d "$p" ]; then
        args+=(--tmpfs "$p")
      elif [ -e "$p" ]; then
        args+=(--ro-bind /dev/null "$p")
      fi
    done

    # The session and system buses can start units outside the jail
    # (systemd-run --user, logind), so hide them along with the other
    # per-user sockets (wayland, pipewire, agents).
    for p in "''${XDG_RUNTIME_DIR:-/run/user/$UID}" /run/dbus; do
      if [ -d "$p" ]; then
        args+=(--tmpfs "$p")
      fi
    done

    exec ${pkgs.bubblewrap}/bin/bwrap "''${args[@]}" -- ${pkgs.claude-code}/bin/claude "$@"
  '';
in
{
  programs.claude-code = {
    enable = true;

    # Wrap claude so the key is read from the file at launch time.
    # setup apiey file:
    # mkdir -p ~/.config/openrouter
    # printf '%s' 'sk-or-v1-...' > ~/.config/openrouter/api_key
    # chmod 600 ~/.config/openrouter/api_key
    package = pkgs.symlinkJoin {
      name = "claude-code-openrouter";
      paths = [ pkgs.claude-code ];
      postBuild = ''
        rm $out/bin/claude
        ln -s ${jail} $out/bin/claude
      '';
    };

    settings = {
      skipDangerousModePermissionPrompt = false;
      model = opus;

      # No apiKeyHelper: auth comes from ANTHROPIC_AUTH_TOKEN via the wrapper.
      env = {
        ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
        # Must be explicitly empty so Claude Code doesn't try Anthropic's own auth.
        ANTHROPIC_API_KEY = "";
        ANTHROPIC_MODEL = opus;
        ANTHROPIC_DEFAULT_OPUS_MODEL = opus;
        ANTHROPIC_DEFAULT_SONNET_MODEL = sonnet;
        ANTHROPIC_DEFAULT_HAIKU_MODEL = haiku;
        ANTHROPIC_SMALL_FAST_MODEL = haiku;
        # Keep the token out of the environment of Bash, hook, and MCP
        # subprocesses; only the Claude process itself needs it.
        CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "1";
      };

      permissions = {
        # Anything not allowed or denied below goes to the auto-mode
        # classifier. The jail in the wrapper is the hard boundary.
        defaultMode = "auto";
        disableBypassPermissionsMode = "disable";
        additionalDirectories = [ ];
        allow = [
          "Read(./**)"
          "Write(./**)"
          "Edit(./**)"
          "Glob"
          "Grep"
          "WebSearch"

          # Evaluate, build, format, and inspect.
          "Bash(nix flake check:*)"
          "Bash(nix flake show:*)"
          "Bash(nix flake metadata:*)"
          "Bash(nix flake prefetch:*)"
          "Bash(nix eval:*)"
          "Bash(nix build:*)"
          "Bash(nix search:*)"
          "Bash(nix path-info:*)"
          "Bash(nix why-depends:*)"
          "Bash(nix derivation show:*)"
          "Bash(nix log:*)"
          "Bash(nix hash:*)"
          "Bash(nix store prefetch-file:*)"
          "Bash(nix-prefetch-url:*)"
          "Bash(nix-instantiate:*)"
          "Bash(nixos-option:*)"
          "Bash(nixfmt:*)"
          "Bash(nixpkgs-fmt:*)"

          # Read-only inspection. These stay inside the bash sandbox (writes
          # limited to the repo, network proxied), which is the backstop for
          # exec-style flags such as `rg --pre`.
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(ls:*)"
          "Bash(wc:*)"
          "Bash(grep:*)"
          "Bash(rg:*)"

          # Read-only git, for the history behind a file.
          "Bash(git log:*)"
          "Bash(git show:*)"
          "Bash(git diff:*)"
          "Bash(git blame:*)"
          "Bash(git status:*)"
          "Bash(git shortlog:*)"
          "Bash(git rev-parse:*)"
          "Bash(git ls-files:*)"
          "Bash(git grep:*)"
        ];
        # Deny wins over allow and over the auto-mode classifier. Activation
        # and imperative state changes are the user's job.
        deny = [
          "Bash(nixos-rebuild:*)"
          "Bash(home-manager:*)"
          "Bash(sudo:*)"
          "Bash(nix flake update:*)"
          "Bash(nix flake lock:*)"
          "Bash(nix-env:*)"
          "Bash(nix profile:*)"
          "Bash(nix run:*)"
          "Bash(nix shell:*)"
          "Bash(nix develop:*)"
          "Bash(nix fmt:*)"
          "Bash(nix-shell:*)"
          "Bash(nix store delete:*)"
          "Bash(nix store gc:*)"
          "Bash(nix-collect-garbage:*)"
          # nix runs outside the bash sandbox (see excludedCommands), so block
          # the flags that let evaluation read arbitrary files, the
          # environment, or run programs (builtins.exec).
          "Bash(nix*--impure*)"
          "Bash(nix*--option*)"
          "Bash(nix*unsafe*)"

          # History rewrites, discarding uncommitted work, and anything
          # that leaves the machine. Commits are the user's job too.
          "Bash(git commit:*)"
          "Bash(git push:*)"
          "Bash(git reset:*)"
          "Bash(git clean:*)"
          "Bash(git checkout:*)"
          "Bash(git restore:*)"
          "Bash(git switch:*)"
          "Bash(git rebase:*)"
          "Bash(git merge:*)"
          "Bash(git cherry-pick:*)"
          "Bash(git revert:*)"
          "Bash(git stash:*)"
          "Bash(git config:*)"
          "Bash(git remote:*)"
          "Bash(git gc:*)"
          "Bash(git filter-branch:*)"
          "Bash(git update-ref:*)"

          # cat/rg can read outside the repo, so keep the API key out of reach.
          "Read(~/.config/openrouter/**)"
          "WebFetch"
          "Agent"
          "Task"
        ];
      };

      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = false;
        allowUnsandboxedCommands = false;
        # The sandbox allows reads almost everywhere by default.
        filesystem.denyRead = [ (builtins.dirOf keyFile) ];
        # The sandbox blocks the nix-daemon socket and masks .gitmodules, so
        # nix can't evaluate or build inside it. Outside it, nix is still
        # confined by the jail, builds still run in nix's own sandbox, and
        # the deny list above blocks impure evaluation. nix-instantiate and
        # nixos-option evaluate impurely by default, so they stay sandboxed
        # and may fail where they need the daemon; nix eval covers both.
        excludedCommands = [
          "nix"
          "nix-prefetch-url"
        ];
      };

      enableAllProjectMcpServers = false;
      disableAllHooks = true;

      statusLine = {
        command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
        padding = 0;
        type = "command";
      };
      theme = "dark";
    };
  };
}
