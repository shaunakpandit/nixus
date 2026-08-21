{ pkgs, ... }: {
  home.packages = with pkgs; [
    cliamp
  ];

  xdg.configFile."cliamp" = {
    source = ../../dots/cliamp;
    recursive = true;
  };
}
