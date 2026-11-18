# Claude Code pieces shared by the hosts (claudeCodeNative.nix) and the claudebox VM (system/claudebox.nix).
{ lib, pkgs, ... }:
let
  # Cost is Claude Code's own estimate from token counts; on a subscription it isn't billed.
  statusLine = pkgs.writeShellScript "claude-statusline" ''
    IFS=$'\t' read -r model directory used tokens size cost < <(${lib.getExe pkgs.jq} -r '[
      .model.display_name,
      (.workspace.current_dir | split("/") | last),
      (.context_window.used_percentage // 0),
      (.context_window.total_input_tokens // 0) / 1000,
      (.context_window.context_window_size // 0) / 1000,
      (.cost.total_cost_usd // 0)
    ] | @tsv')
    printf '[%s] 📁 %s | ctx %.0f%% (%.0fk/%.0fk) | $%.2f' \
      "$model" "$directory" "$used" "$tokens" "$size" "$cost"
  '';
in
{
  programs.claude-code = {
    enable = true;

    plugins.ponytail = pkgs.fetchFromGitHub {
      owner = "DietrichGebert";
      repo = "ponytail";
      rev = "96608e078b2d5ea607c5c3b8b5a54d1c1fba6846";
      hash = "sha256-PhPtZbeX2wBp19GtWRy+fV93+fFYZe5S487eXPDl/us=";
    };

    settings = {
      effortLevel = lib.mkDefault "high";
      # Claude Code ranks model defaults/experiments above effortLevel; the env var beats them.
      env.CLAUDE_CODE_EFFORT_LEVEL = lib.mkDefault "high";
      # true would also suppress the status line.
      disableAllHooks = false;
      statusLine = {
        command = "${statusLine}";
        padding = 0;
        type = "command";
      };
    };
  };
}
