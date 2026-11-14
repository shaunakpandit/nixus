{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mytools.gostartools.enable = lib.mkEnableOption "gostartools";

  config = lib.mkIf config.mytools.gostartools.enable {
    home.packages = [
      (pkgs.buildGoModule {
        pname = "gostartools";
        version = "0-unstable-2026-11-13";
        src = pkgs.fetchFromGitHub {
          owner = "shaunakpandit";
          repo = "gostartools";
          rev = "b0e671b921f12de71e6b2276eb06be9a86f29ddd";
          hash = "sha256-pkx1Hd3LXCD/6RQUjjKQcyLFSwTTHboLTDKR+vxXy+M=";
        };
        # Unlike gowifi this has dependencies, so it needs a real hash.
        vendorHash = "sha256-P3iFBhlDRS+bTfGRwy2bTPmi83HgIOMPKI364SRUouI=";
        meta.mainProgram = "sctool";
      })
    ];
  };
}
