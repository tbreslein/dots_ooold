{
  description = "nixos+hm flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager
    , neovim-nightly-overlay, darwin, ... }:
    let
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
      userName = "tommy";
      overlays = [ neovim-nightly-overlay.overlay ];
      commonInherits = { inherit inputs colors userName overlays; };
      homeConfModules = [
        ./modules/cli
        ./modules/coding
        ./modules/desktop
        ./modules/desktop/linux.nix
        ./modules/desktop/wayland.nix
        ./modules/desktop/x11.nix
        ./modules/home
        ./modules/up
      ];
      systemConfModules = [ ./modules/system ./modules/system/desktop.nix ];
      mkNixos = name: system: systemModules:
        let
          pkgs-unstable = import nixpkgs-unstable { inherit system; };
          localInherits = commonInherits // { inherit pkgs-unstable; };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = localInherits;
          modules = systemConfModules ++ systemModules ++ [
            (./hosts + "/${name}/configuration.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = localInherits;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${userName}.imports = homeConfModules
                  ++ [ (./hosts + "/${name}/home.nix") ];
              };
            }
          ];
        };
    in {
      nixosConfigurations = {
        moebius =
          mkNixos "moebius" "x86_64-linux" [ ./modules/system/linux.nix ];
        audron = mkNixos "audron" "x86_64-linux" [ ./modules/system/linux.nix ];
        moebius-win = mkNixos "moebius-win" "x86_64-linux" [
          ./modules/system/linux.nix
          ./modules/system/wsl.nix
        ];
        vorador = mkNixos "vorador" "aarch64-linux" [
          ./modules/system/linux.nix
          ./modules/system/aarch64-linux.nix
        ];
      };
      darwinConfigurations.Tommys-MacBook-Pro = let
        system = "aarch64-darwin";
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        localInherits = commonInherits // { inherit pkgs-unstable; };
      in darwin.lib.darwinSystem {
        inherit system;
        specialArgs = localInherits;
        modules = [
          ./modules/system
          ./modules/system/aarch64-darwin.nix

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = localInherits;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${userName}.imports = homeConfModules
                ++ [ ./hosts/macbook/home.nix ];
            };
          }
        ];
      };
    };
}
