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
      onedark = rec {
        background = black;
        foreground = "abb2bf";
        bright_foreground = brightWhite;
        black = "1e2127";
        red = "e06c75";
        green = "98c379";
        yellow = "d19a66";
        blue = "61afef";
        magenta = "c678dd";
        cyan = "56b6c2";
        white = "828791";

        brightBlack = "5c6370";
        brightRed = "e06c75";
        brightGreen = "98c379";
        brightYellow = "d19a66";
        brightBlue = "61afef";
        brightMagenta = "c678dd";
        brightCyan = "56b6c2";
        brightWhite = "e6efff";

        dimBlack = black;
        dimRed = red;
        dimGreen = green;
        dimYellow = yellow;
        dimBlue = blue;
        dimMagenta = magenta;
        dimCyan = cyan;
        dimWhite = white;

        accent = cyan;
        border = blue;
      };
      colors = onedark;
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
