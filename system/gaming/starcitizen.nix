{ pkgs, inputs, ... }:
{
  nix.settings = {
    substituters = [ "https://nix-citizen.cachix.org" ];
    trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  };
  environment.systemPackages = with pkgs; [
    # `home.packages` if using home manager
    # replace or repeat for any included package
    inputs.nix-citizen.packages.${system}.rsi-launcher
  ];
}
