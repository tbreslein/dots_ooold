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

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      moebius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./nixos/configuration.nix] ;
      };
    };
  };
}
