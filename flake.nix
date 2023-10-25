{
  description = "nixos+hm flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      moebius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./nixos/configuration.nix] ;
      };
    };
  };
}
