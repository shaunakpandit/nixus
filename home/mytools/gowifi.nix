{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mytools.gowifi.enable = lib.mkEnableOption "gowifi";

  config = lib.mkIf config.mytools.gowifi.enable {
    home.packages = [
      (pkgs.buildGoModule {
        pname = "gowifi";
        version = "0-unstable-2026-11-12";

        src = pkgs.fetchFromGitHub {
          owner = "shaunakpandit";
          repo = "gowifi";
          rev = "036eecdb66efab9261f4dba61e2689c4f477e3e0";
          hash = "sha256-+jVfyBca4NyaE4o5aTNVeQt4yuvFE5ojTwRz9xheLuI=";
        };

        vendorHash = null;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        # Shells out to nmcli and stty at runtime.
        postInstall = ''
          wrapProgram $out/bin/gowifi --prefix PATH : ${
            lib.makeBinPath [
              pkgs.networkmanager
              pkgs.coreutils
            ]
          }
        '';

        meta.mainProgram = "gowifi";
      })
    ];
  };
}
