{
  description = "nixos+hm flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, ... }:
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
      userConfig = rec {
        name = "tommy";
        # options: hyprland, dk
        wm = "hyprland";
        isWaylandWM = wm == "hyprland";
        # theme = "gruvbox-material";
        # colors = if theme == "gruvbox-material" then rec {
        #   background = "1d2021";
        #   foreground = white;
        #   bright_foreground = brightWhite;
        #   black = "32302f";
        #   red = "ea6962";
        #   green = "a9b665";
        #   yellow = "d8a657";
        #   blue = "7daea3";
        #   magenta = "d3869b";
        #   cyan = "89b482";
        #   white = "d4be98";
        #
        #   brightBlack = black;
        #   brightRed = red;
        #   brightGreen = green;
        #   brightYellow = yellow;
        #   brightBlue = blue;
        #   brightMagenta = magenta;
        #   brightCyan = cyan;
        #   brightWhite = white;
        #
        #   dimBlack = black;
        #   dimRed = red;
        #   dimGreen = green;
        #   dimYellow = yellow;
        #   dimBlue = blue;
        #   dimMagenta = magenta;
        #   dimCyan = cyan;
        #   dimWhite = white;
        #
        #   accent = yellow;
        #   border = yellow;
        # } else
        #   { };
      };
      homeConfModules = [
        ./modules/cli
        ./modules/coding
        ./modules/desktop
        ./modules/desktop/linux.nix
        ./modules/desktop/wayland.nix
        ./modules/desktop/x11.nix
        ./modules/home
        ./modules/up
        inputs.ags.homeManagerModules.default
      ];
      systemConfModules = [ ./modules/system ./modules/system/desktop.nix ];
      mkNixos = name: system: systemModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs colors; };
          modules = systemConfModules ++ systemModules ++ [
            (./hosts + "/${name}/configuration.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs colors; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tommy.imports = homeConfModules
                  # ++ [ (./hosts + ("/" + name + "/home.nix")) ];
                  ++ [ (./hosts + "/${name}/home.nix") ];
              };
            }
          ];
        };
    in {
      nixosConfigurations = {
        moebius = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit userConfig inputs; };
          modules = [
            ./system
            ./system/linux
            ./system/linux-desktop
            ./system/hosts/moebius

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit userConfig inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tommy.imports = [
                  ./home
                  ./home/shell
                  ./home/coding
                  ./home/hosts/moebius
                  ./home/private
                  ./home/linux
                  ./home/desktop
                  ./home/linux-desktop
                  (if userConfig.isWaylandWM then
                    ./home/linux-desktop/wayland
                  else
                    ./home/linux-desktop/x11)
                ];
              };
            }
          ];
        };
        moebius-win = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit userConfig inputs; };
          modules = [
            ./system
            ./system/linux
            ./system/wsl
            ./system/hosts/moebius-win

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit userConfig inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tommy.imports = [
                  ./home
                  ./home/shell
                  ./home/coding
                  #./home/hosts/moebius-win
                  ./home/private
                  ./home/linux
                ];
              };
            }
          ];
        };
        audron = mkNixos "audron" "x86_64-linux" [ ./modules/system/linux.nix ];
        # ONLY KINDA OLD
        # audron = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = { inherit inputs; };
        #   modules = systemConfModules ++ [
        #     ./hosts/audron/configuration.nix
        #
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager = {
        #         extraSpecialArgs = { inherit inputs; };
        #         useGlobalPkgs = true;
        #         useUserPackages = true;
        #         users.tommy.imports = homeConfModules
        #           ++ [ ./hosts/audron/home.nix ];
        #       };
        #     }
        #   ];
        # };
        # VERY OLD
        # audron = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = { inherit userConfig inputs; };
        #   modules = [
        #     ./system
        #     ./system/linux
        #     ./system/linux-desktop
        #     ./system/hosts/audron
        #
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager = {
        #         extraSpecialArgs = { inherit userConfig inputs; };
        #         useGlobalPkgs = true;
        #         useUserPackages = true;
        #         users.tommy.imports = [
        #           ./home
        #           ./home/shell
        #           ./home/coding
        #           ./home/hosts/audron
        #           ./home/private
        #           ./home/linux
        #           ./home/desktop
        #           ./home/linux-desktop
        #           (if userConfig.isWaylandWM then
        #             ./home/linux-desktop/wayland
        #           else
        #             ./home/linux-desktop/x11)
        #         ];
        #       };
        #     }
        #   ];
        # };
        vorador = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit userConfig inputs; };
          modules = [
            ./system
            ./system/linux
            ./system/hosts/vorador

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit userConfig inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tommy.imports = [
                  ./home
                  ./home/hosts/vorador
                  ./home/private
                  ./home/shell
                  ./home/linux
                ];
              };
            }
          ];
        };
      };
      darwinConfigurations.Tommys-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system
          ./system/mac

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit userConfig; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.tommy.imports = [
                ./home
                ./home/shell
                ./home/coding
                ./home/mac
                ./home/work
                ./home/desktop
              ];
            };
          }
        ];
      };
    };
}
