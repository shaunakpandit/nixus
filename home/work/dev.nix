{ pkgs, ... }:
let
  # Global default; pin per-project versions with devenv's languages.php.version
  php = pkgs.php85;
  dotnet = pkgs.dotnetCorePackages.sdk_10_0;
in
{
  home.packages = with pkgs; [
    php
    php.packages.composer
    nodejs_24
    typescript
    dotnet
  ];

  home.sessionVariables.DOTNET_ROOT = "${dotnet}/share/dotnet";
}
