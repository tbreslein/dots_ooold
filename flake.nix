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
      theme = "gruvbox-material";
      colors = if theme == "gruvbox-material" then rec {
        background = "1d2021";
        foreground = white;
        bright_foreground = brightWhite;
        black = "32302f";
        red = "ea6962";
        green = "a9b665";
        yellow = "d8a657";
        blue = "7daea3";
        magenta = "d3869b";
        cyan = "89b482";
        white = "d4be98";

        brightBlack = black;
        brightRed = red;
        brightGreen = green;
        brightYellow = yellow;
        brightBlue = blue;
        brightMagenta = magenta;
        brightCyan = cyan;
        brightWhite = white;

        dimBlack = black;
        dimRed = red;
        dimGreen = green;
        dimYellow = yellow;
        dimBlue = blue;
        dimMagenta = magenta;
        dimCyan = cyan;
        dimWhite = white;

        accent = yellow;
        border = yellow;
      } else
        { };
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
              extraSpecialArgs = { inherit userConfig colors; };
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
