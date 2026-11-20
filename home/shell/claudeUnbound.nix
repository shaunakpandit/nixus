# claudeCodeNative (plugins, CLAUDE.md, MCP, status line) with every permission granted except the denies below.
{ lib, pkgs, ... }:
{
  imports = [ ./claudeCodeNative.nix ];

  # Headless browser, set up like claudebox: the skill ships with agent-browser,
  # and nixpkgs' chromium replaces the one agent-browser would download.
  home.packages = [
    pkgs.agent-browser
    pkgs.chromium
  ];
  home.sessionVariables.AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
  programs.claude-code.skills.agent-browser = "${pkgs.agent-browser}/skills/agent-browser";

  programs.claude-code.settings = {
    skipDangerousModePermissionPrompt = lib.mkForce true;
    sandbox.enabled = lib.mkForce false;
    # mkForce because settings lists concatenate, which would keep Native's allow/deny lists.
    permissions = lib.mkForce {
      defaultMode = "bypassPermissions";
      # Deny rules still apply in bypassPermissions mode.
      deny = [
        "Bash(rm:*)"

        "Bash(git push*--force*)"
        "Bash(git push* -f*)"
        "Bash(git push* +*)"

        "Bash(sudo:*)"
        "Bash(su:*)"
        "Bash(doas:*)"
        "Bash(pkexec:*)"
        "Bash(run0:*)"
        "Bash(systemd-run:*)"
        "Bash(machinectl:*)"
        "Bash(nixos-rebuild:*)"
      ];
    };
  };
}
