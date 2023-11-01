{
  description = "nixos+hm flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }:
    let
      userConfig = rec {
        name = "tommy";
        linuxShell = "bash";
        # options: hyprland, dk
        wm = "dk";
        isWaylandWM = wm == "hyprland";
        isXWM = !isWaylandWM;
        linkConfig = config: name: {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dots/config/${name}";
          target = "${config.home.homeDirectory}/.config/${name}";
        };
      };
    in {
      nixosConfigurations.moebius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit userConfig; };
        modules = [
          ./nixos/moebius.nix
          ./nixos/moebius-hardware.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit userConfig; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.tommy = import ./hm/moebius.nix;
            };
          }
        ];
      };
      darwinConfigurations.Tommys-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nix-darwin/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit userConfig; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.tommy = import ./hm/mac.nix;
            };
          }
        ];
      };
    };
}
