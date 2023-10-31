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
      userConfig = rec {
        name = "tommy";
        linuxShell = "bash";
        # options: hyprland, plasma
        wm = "plasma";
        isWaylandWM = wm == "hyprland";
        isWaylandDE = wm == "plasma";
        # isX = !wm;
        linkConfig = config: name: {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dots/config/${name}";
          target = "${config.home.homeDirectory}/.config/${name}";
        };
      };
    in {
      nixosConfigurations = {
        moebius = nixpkgs.lib.nixosSystem {
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
      };
    };
}
