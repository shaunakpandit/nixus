{ pkgs, ... }: {
  home.packages = with pkgs; [
    cliamp
  ];
}
