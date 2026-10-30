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
in
{
  programs.claude-code = {
    enable = true;
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

    # Wrap claude so the key is read from the file at launch time.
    # setup apiey file:
    # mkdir -p ~/.config/openrouter
    # printf '%s' 'sk-or-v1-...' > ~/.config/openrouter/api_key
    # chmod 600 ~/.config/openrouter/api_key
    package = pkgs.symlinkJoin {
      name = "claude-code-openrouter";
      paths = [ pkgs.claude-code ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # The formatters otherwise only exist on nvim's PATH (extraPackages),
      # so expose them to Claude's shell too.
      postBuild = ''
        wrapProgram $out/bin/claude \
          --prefix PATH : ${
            lib.makeBinPath [
              pkgs.nixfmt-rs
              pkgs.nixpkgs-fmt
            ]
          } \
          --run 'export ANTHROPIC_AUTH_TOKEN="$(cat ${keyFile})"'
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
      };

      permissions = {
        defaultMode = "dontAsk";
        additionalDirectories = [ ];
        allow = [
          "Read(./**)"
          "Write(./**)"
          "Edit(./**)"
          "Glob"
          "Grep"
          "WebSearch"

          # Evaluate, build, format, and inspect. With defaultMode = "dontAsk",
          # any shell command not listed here is refused.
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
        # Not reachable via the allow list anyway; listed so they stay blocked
        # even if defaultMode is relaxed. Activation and imperative state
        # changes are the user's job.
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

          "Bash(sudo:*)"
        ];
      };

      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = false;
        allowUnsandboxedCommands = false;
        # The sandbox blocks the nix-daemon socket and writes to ~/.cache/nix,
        # so nix can't evaluate or build inside it. Builds still run in nix's
        # own sandbox, and only the subcommands allowed above can run.
        excludedCommands = [
          "nix"
          "nix-instantiate"
          "nix-prefetch-url"
          "nixos-option"
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
