{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "plexamp-tui";
  version = "unstable-2026-08-02";

  src = fetchFromGitHub {
    owner = "spiercey";
    repo = "plexamp-tui";
    rev = "35b7cbd4d79581e402898f4a4d438faee7395977";
    hash = "sha256-6NxcrfWlNenaCLP8ODsX+u3iXs03cgOseKXHt04AN1M=";
  };

  vendorHash = "sha256-mcaVBbeDbgWDd6+S5t9BhqsVHWeRGDZqZYeRQ0eYwEE=";

  # The Go main package is at the repository root.
  subPackages = [ "." ];

  meta = {
    description = "Terminal user interface for Plexamp";
    homepage = "https://github.com/spiercey/plexamp-tui";
    license = lib.licenses.mit; # Verify against the repository's license
    mainProgram = "plexamp-tui";
    platforms = lib.platforms.unix;
  };
}
