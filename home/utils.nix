{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.rustup ];

  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [ "${config.xdg.dataHome}/cargo/bin" ];
}
