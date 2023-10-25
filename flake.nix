{
  description = "nixos+hm flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    trusted-users = [ "tommy" ];
  };

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
          "${config.home.homeDirectory}/dots/config${name}";
        target = "${config.home.homeDirectory}/.config/${name}";
      };
    in {
    nixosConfigurations = {
      moebius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          ./nixos/moebius.nix
          ./nixos/moebius-hardware.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit user_name mk_config; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tommy = import ./hm/home.nix;
          }
        ] ;
      };
    };
  };
}
