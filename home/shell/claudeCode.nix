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
      # so expose them to Claude's shell too. ripgrep is pinned here because
      # this Claude Code build has no Grep/Glob tools and searches via Bash.
      postBuild = ''
        wrapProgram $out/bin/claude \
          --prefix PATH : ${
            lib.makeBinPath [
              pkgs.nixfmt-rs
              pkgs.nixpkgs-fmt
              pkgs.ripgrep
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
        ];
        # Not reachable via the allow list anyway; listed so they stay blocked
        # even if defaultMode is relaxed. Activation and imperative state
        # changes are the user's job.
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
          "Bash(nix-shell:*)"
          "Bash(nix store delete:*)"
          "Bash(nix store gc:*)"
          "Bash(nix-collect-garbage:*)"
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
