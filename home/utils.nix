{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.rustup
  ];

  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "${config.xdg.dataHome}/cargo/bin"
  ];

  home.activation.rustupDefaultStable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "${config.xdg.dataHome}/cargo/bin/rustup" ]; then
      exit 0
    fi

    export RUSTUP_HOME="${config.xdg.dataHome}/rustup"
    export CARGO_HOME="${config.xdg.dataHome}/cargo"

    if [ ! -e "$RUSTUP_HOME/settings.toml" ]; then
      ${pkgs.rustup}/bin/rustup toolchain install stable
      ${pkgs.rustup}/bin/rustup default stable
    fi
  '';
}
