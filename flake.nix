{
  description = "NixOS hosts: t14, d4080, thoth, rama, thea";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar-git = {
      url = "github:Alexays/Waybar?rev=30610d3b68f109e950d924bc7d9c42b8cbbc5df8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium.url = "gitlab:ntgn/helium-flake";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      # A host is hosts/<name>/configuration.nix, plus hosts/<name>/home.nix for var.username.
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${name}/configuration.nix
            home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  extraSpecialArgs = { inherit inputs; };
                  users.${config.var.username}.imports = [ ./hosts/${name}/home.nix ];
                };
              }
            )
          ];
        };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      # `nix flake check` runs these and evaluates every host (including each module's assertions).
      checks.x86_64-linux = import ./checks.nix {
        inherit pkgs;
        src = ./.;
        hosts = inputs.self.nixosConfigurations;
      };
      formatter.x86_64-linux = pkgs.nixfmt-rs;
      ports = builtins.mapAttrs (
        _: (import ./ports.nix { inherit (nixpkgs) lib; }).report
      ) inputs.self.nixosConfigurations;

      # `nix develop` provides the tools for creating keys and editing secrets/
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          sops
          age
          ssh-to-age
        ];
      };

      nixosConfigurations = {
        t14 = mkHost "t14";
        d4080 = mkHost "d4080";
        thoth = mkHost "thoth";
        rama = mkHost "rama";
        thea = mkHost "thea";
      };
    };
}
