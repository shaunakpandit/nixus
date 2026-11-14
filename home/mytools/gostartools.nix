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
          rev = "d85adc844ef6e9e6654244ce9c5351c0db547062";
          hash = "sha256-sI3PuVwn8KtBJTQaCigInDO1MfsdlcHm+/9MPaCZPO4=";
        };
        # Unlike gowifi this has dependencies, so it needs a real hash.
        vendorHash = "sha256-sI3PuVwn8KtBJTQaCigInDO1MfsdlcHm+/9MPaCZPO4=";
        meta.mainProgram = "sctool";
      })
    ];
  };
}
