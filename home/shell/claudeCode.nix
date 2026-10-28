{ ... }:

{
  programs.claude-code = {
    enable = true;

    settings = {
      # Do not bypass permission checks.
      skipDangerousModePermissionPrompt = false;

      permissions = {
        # Deny operations that would otherwise require a permission prompt.
        defaultMode = "dontAsk";

        # No additional working directories.
        additionalDirectories = [ ];

        allow = [
          "Read(./**)"
          "Write(./**)"
          "Edit(./**)"
          "Glob"
          "Grep"
          "WebSearch"
        ];

        deny = [
          # No shell, including curl, wget, scripts, package managers, etc.
          "Bash"

          # Allow search, but not arbitrary URL fetching.
          "WebFetch"

          # Prevent delegation to agents with a potentially broader toolset.
          "Agent"
          "Task"
        ];
      };

      # Defense in depth if shell access is enabled later.
      # This does not itself restrict all Claude tools.
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = false;
        allowUnsandboxedCommands = false;
      };

      # Do not automatically enable project-provided MCP servers.
      enableAllProjectMcpServers = false;

      # Do not execute hooks supplied through Claude configuration.

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
