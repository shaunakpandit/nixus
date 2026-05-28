{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };
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
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-citizen.url = "github:LovingMelody/nix-citizen";
  };

  outputs =
    {
      self,
      nixpkgs,
      chaotic,
      home-manager,
      mangowm,
      stylix,
      firefox-addons,
      nixos-hardware,
      nix-citizen,
      ...
    }@inputs:
    {
      # Please replace my-nixos with your hostname
      nixosConfigurations = {
        t14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./hosts/t14/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.void = {
                imports = [
                  ./hosts/t14/home.nix
                  inputs.mangowm.hmModules.mango
                ];
              };
            }
            nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
            mangowm.nixosModules.mango
            stylix.nixosModules.stylix
            chaotic.nixosModules.default
          ];
        };

        d4080 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./hosts/d4080/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.void = {
                imports = [
                  ./hosts/d4080/home.nix
                  inputs.mangowm.hmModules.mango
                ];
              };
            }
            mangowm.nixosModules.mango
            stylix.nixosModules.stylix
            chaotic.nixosModules.default
          ];
        };

        s1080 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./hosts/s1080/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.void = {
                imports = [
                  ./hosts/s1080/home.nix
                ];
              };
            }
            stylix.nixosModules.stylix
          ];
        };

      };
    };
}
