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
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, darwin, nix-colors, ... }:
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
      my-colors = rec {
        base = nix-colors.colorSchemes.onedark;

        background = black;
        foreground = white;
        black = base.base00;
        red = base.base01;
        green = base.base02;
        yellow = base.base03;
        blue = base.base04;
        magenta = base.base05;
        cyan = base.base06;
        white = base.base07;

        brightBlack = base.base08;
        brightRed = base.base09;
        brightGreen = base.base0A;
        brightYellow = base.base0B;
        brightBlue = base.base0C;
        brightMagenta = base.base0D;
        brightCyan = base.base0E;
        brightWhite = base.base0F;

        # onedark
        accent = cyan;
        border = blue;

        # gruvbox
        # accent = yellow;
        # border = yellow;
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
              extraSpecialArgs = { inherit userConfig nix-colors my-colors; };
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
