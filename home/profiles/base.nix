# Terminal and dev tooling for every host. Keep it free of Linux-only things so macOS hosts can use it too.
{
  imports = [
    ../../var.nix
    ../shell/shell.nix
    ../shell/utils.nix
    ../shell/dev.nix
    ../shell/nvim.nix
    ../mytools
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
  };
}
