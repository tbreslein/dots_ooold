{
  description = "Home Manager configuration of tommy";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      common_modules = [ ./nix/home.nix ];
      user_name = "tommy";
    in {
      homeConfigurations = {
        "tommy@moebius" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = { inherit user_name; };
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = common_modules ++ [ ./nix/linux.nix ./nix/moebius.nix ];
        };
        "tommy@audron" = home-manager.lib.homeManagerConfiguration {
          specialArgs = { inherit user_name; };
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          home_dir = "/home/${user_name}";
          modules = common_modules ++ [ ./nix/linux.nix ./nix/audron.nix ];
        };
        mac = home-manager.lib.homeManagerConfiguration rec {
          specialArgs = { inherit user_name; };
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          home_dir = "/Users/tommy";
          modules = common_modules ++ [ ./nix/darwin.nix ];
        };
      };
    };
}
