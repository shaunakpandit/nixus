{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  # Lives outside the repo; never enters git or the Nix store.
  # setup api key file:
  # mkdir -p ~/.config/openrouter
  # printf '%s' 'sk-or-v1-...' > ~/.config/openrouter/api_key
  # chmod 600 ~/.config/openrouter/api_key
  keyFile = "${config.home.homeDirectory}/.config/openrouter/api_key";
  # Claude's home inside the container: sessions, ~/.claude.json, nix caches.
  stateDir = "${config.xdg.dataHome}/claude-box";
  # Mounted at /scratch, for handing Claude files without mounting their directory.
  scratchDir = "${config.home.homeDirectory}/claude-scratch";

  opus = "anthropic/claude-opus-5.5";
  sonnet = "anthropic/claude-sonnet-5.5";
  haiku = "anthropic/claude-haiku-5.5";

  # /etc/claude-code/CLAUDE.md, loaded in every project alongside its own CLAUDE.md.
  memory = ''
    # Global rules

    ## Code style

    - Write clean, concise code. Prefer the shortest clear solution and avoid needless abstraction, indirection, or boilerplate.
    - Don't over-comment. Comment the why (workarounds, non-obvious decisions), never the what.
    - Prefer a functional style wherever the language allows: pure functions, immutable data, expressions over statements, and `map`/`filter`/`reduce` over loops that mutate state.
    - Use full, descriptive names with no abbreviations: `number` not `num`, `index` not `idx`, `message` not `msg`, `button` not `btn`.
    - Reuse before writing. Look for an existing function that does the job, and extend or generalize it instead of adding a near-duplicate.
    - Match the style of the surrounding code.

    ## Communication

    - Be brief. Lead with the answer and skip preamble and recaps.

    ## Bash tools

    Use:
    - The Read, Edit, and Write tools to read and change files.
    - `rg` to search file contents, and `rg --files` to find files.
    - `git log`, `git show`, `git diff`, and `git blame` for history and context.
    - `jq` to query JSON.
    - The project's own build, check, test, and format commands.

    Don't use:
    - `cat`, `head`, `tail`, or `less` to read files. Use Read.
    - `sed`, `awk`, `perl -i`, `echo`/`printf` redirects, or heredocs to create or edit files. Use Edit or Write.
    - `grep`, `find`, or `ls -R`. Use `rg`.
    - `sudo`, or global installers (`npm install -g`, `pip install`, `cargo install`, `go install`, `nix profile`, `nix-env`).
    - `curl` or `wget` piped into a shell, or hand-downloaded binaries.
    - Destructive commands: `rm -rf`, `git reset --hard`, `git clean`, `git checkout --`, `git push --force`, or `chmod`/`chown` fixes.
    - `git commit` or `git push` unless asked.
  '';

  # /etc/claude-code/managed-settings.json, which outranks any settings file
  # Claude could write itself.
  settings = {
    model = opus;

    # No apiKeyHelper: auth comes from ANTHROPIC_AUTH_TOKEN via the launcher.
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
      # classifier. The container is the hard boundary.
      defaultMode = "auto";
      disableBypassPermissionsMode = "disable";
      additionalDirectories = [ "/scratch" ];
      allow = [
        "Read"
        "Write(./**)"
        "Edit(./**)"
        "Write(//scratch/**)"
        "Edit(//scratch/**)"
        "Glob"
        "Grep"
        "WebSearch"

        # Evaluate, build, format, and inspect.
        "Bash(nix:*)"
        "Bash(nix-instantiate:*)"
        "Bash(nix-prefetch-url:*)"
        "Bash(nix-hash:*)"
        "Bash(nix-store:*)"
        "Bash(nixfmt:*)"
        "Bash(nixpkgs-fmt:*)"

        "Bash(cat:*)"
        "Bash(head:*)"
        "Bash(tail:*)"
        "Bash(ls:*)"
        "Bash(wc:*)"
        "Bash(grep:*)"
        "Bash(rg:*)"
        "Bash(fd:*)"
        "Bash(jq:*)"

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
      # Deny wins over allow and over the auto-mode classifier.
      deny = [
        # The host nix-daemon honors garbage collection from any user, so
        # these are only blocked here.
        "Bash(nix store gc:*)"
        "Bash(nix store delete:*)"
        "Bash(nix store optimise:*)"
        "Bash(nix-collect-garbage:*)"
        "Bash(nix-store --gc:*)"
        "Bash(nix-store --delete:*)"
        "Bash(nix-store --optimise:*)"

        # Installing or running packages from outside the project.
        "Bash(nix profile:*)"
        "Bash(nix-env:*)"
        "Bash(nix run:*)"
        "Bash(nix shell:*)"
        "Bash(nix-shell:*)"
        "Bash(nix develop:*)"
        "Bash(nix fmt:*)"

        # Activation and lock bumps are the user's job. Activation can't work
        # in the container anyway (no root, systemd, or system profile).
        "Bash(nixos-rebuild:*)"
        "Bash(home-manager:*)"
        "Bash(nix flake update:*)"
        "Bash(nix flake lock:*)"

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

        "WebFetch"
        "Agent"
        "Task"
      ];
    };

    # bwrap can't nest inside the container, which is the sandbox instead.
    sandbox.enabled = false;
    enableAllProjectMcpServers = false;
    disableAllHooks = true;

    statusLine = {
      command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
      padding = 0;
      type = "command";
    };
    theme = "dark";
  };

  # No package managers, curl, or wget: nix is the only way in.
  tools = with pkgs; [
    claude-code
    osConfig.nix.package
    nixfmt-rs
    nixpkgs-fmt
    git
    bashInteractive
    coreutils
    findutils
    diffutils
    gnugrep
    gnused
    gawk
    less
    procps
    which
    ripgrep
    fd
    jq
  ];

  # The host store and nix-daemon socket are bind-mounted in, so the image
  # carries no store paths of its own. nix reaches the daemon as the
  # untrusted host user, and the root filesystem is mounted read-only.
  image = pkgs.dockerTools.streamLayeredImage {
    name = "claude-box";
    includeStorePaths = false;
    contents = with pkgs.dockerTools; [
      fakeNss
      usrBinEnv
      binSh
      caCertificates
      (pkgs.writeTextDir "etc/claude-code/managed-settings.json" (builtins.toJSON settings))
      (pkgs.writeTextDir "etc/claude-code/CLAUDE.md" memory)
    ];
    extraCommands = "mkdir -p tmp root scratch";
    config = {
      Cmd = [
        "${pkgs.coreutils}/bin/sleep"
        "infinity"
      ];
      Env = [
        "PATH=${lib.makeBinPath tools}"
        "HOME=/root"
        "LANG=C.UTF-8"
        "NIX_REMOTE=daemon"
        "NIX_CONFIG=experimental-features = nix-command flakes"
        "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
        "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
        "TERMINFO_DIRS=${pkgs.ncurses}/share/terminfo"
      ];
    };
  };

  # claude-box [claude ARGS... | shell | stop]
  # One container per project (the git toplevel of the current directory),
  # mounted at its host path. Every session started there joins it.
  box = pkgs.writeShellApplication {
    name = "claude-box";
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
    ];
    text = ''
      project="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
      if [ "$project" = "$HOME" ] || [ "$project" = / ]; then
        echo "claude-box: refusing to mount $project" >&2
        exit 1
      fi
      name="claude-box-$(printf %s "$project" | sha256sum | cut -c1-12)"
      image=${image.imageName}:${image.imageTag}
      command="''${1:-claude}"
      shift || true

      if [ "$command" = stop ]; then
        exec docker stop "$name"
      fi

      if [ -z "$(docker ps -q --filter "name=^$name$")" ]; then
        docker image inspect "$image" >/dev/null 2>&1 || ${image} | docker load
        mkdir -p ${stateDir} ${scratchDir}
        docker run -d --rm --init --name "$name" \
          --read-only --tmpfs /tmp \
          --cap-drop ALL --security-opt no-new-privileges \
          -v /nix/store:/nix/store:ro \
          -v /nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro \
          -v ${stateDir}:/root \
          -v ${scratchDir}:/scratch \
          -v "$project:$project" \
          "$image" >/dev/null
      fi

      tty=()
      if [ -t 0 ]; then tty=(-t); fi
      case "$command" in
        shell) exec docker exec -i "''${tty[@]}" -w "$PWD" "$name" bash ;;
        claude)
          # Passed by name so the value never shows up in ps.
          ANTHROPIC_AUTH_TOKEN="$(< ${keyFile})"
          export ANTHROPIC_AUTH_TOKEN
          exec docker exec -i "''${tty[@]}" -e ANTHROPIC_AUTH_TOKEN -e COLORTERM -w "$PWD" "$name" claude "$@"
          ;;
        *)
          echo "usage: claude-box [claude ARGS... | shell | stop]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = [
    box
    (pkgs.writeShellScriptBin "claude" ''exec ${box}/bin/claude-box claude "$@"'')
  ];
}
