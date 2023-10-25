{
  description = "nixos+hm flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      user_name = "tommy";
      mk_config = config: name: {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dots/config/${name}";
        target = "${config.home.homeDirectory}/.config/${name}";
      };
    in {
      nixosConfigurations = {
        moebius = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/moebius.nix
            ./nixos/moebius-hardware.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit user_name mk_config; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tommy = import ./hm/moebius.nix;
              };
            }
          ];
        };
      };
    };
}
