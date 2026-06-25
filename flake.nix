{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
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
    helium.url = "gitlab:ntgn/helium-flake";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mangowm,
      stylix,
      firefox-addons,
      nixos-hardware,
      nix-citizen,
      helium,
      nix-cachyos-kernel,
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
                  inputs.helium.homeModules.helium
                ];
              };
            }
            nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
            mangowm.nixosModules.mango
            stylix.nixosModules.stylix
            helium.nixosModules.helium
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  # Use nixpkgs from your environment, nixpkgs.config will apply.
                  # Has small chance of kernel modules not being compatible with kernel version.
                  nix-cachyos-kernel.overlays.default

                  # Alternatively, use the exact nixpkgs revision as defined in this repo.
                  # Guarantees you have binary cache, but initializes another nixpkgs instance.
                  # nix-cachyos-kernel.overlays.pinned

                  # Only use one of the two overlays!
                ];
              }
            )
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
                  inputs.helium.homeModules.helium
                ];
              };
            }
            mangowm.nixosModules.mango
            stylix.nixosModules.stylix
            helium.nixosModules.helium
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  # Use nixpkgs from your environment, nixpkgs.config will apply.
                  # Has small chance of kernel modules not being compatible with kernel version.
                  nix-cachyos-kernel.overlays.default

                  # Alternatively, use the exact nixpkgs revision as defined in this repo.
                  # Guarantees you have binary cache, but initializes another nixpkgs instance.
                  # nix-cachyos-kernel.overlays.pinned

                  # Only use one of the two overlays!
                ];
              }
            )
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
