{
  description = "Home Manager configuration of tommy";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, ... } :
    let
      common_hm_modules = [ ./hm/home.nix ];
      common_nixos_modules = [ ./nixos/configuration.nix ];
      #user_name = "tommy";
      mk_config = config: name: {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dots/config/${name}";
        target = "${config.home.homeDirectory}/.config/${name}";
      };
    in {
      nixosConfigurations = {
        moebius = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = common_nixos_modules ++ [
            ./nixos/moebius.nix ./nixos/moebius-hardware.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit mk_config; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tommy = import (common_hm_modules ++ [ ./hm/linux.nix ./hm/moebius.nix ]);
            }
          ];
        };
      };
      darwinConfigurations = {
        mac = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tommy = import (common_hm_modules ++ [ ./hm/darwin.nix ]);
            }
          ];
        };
      };
    };
}
