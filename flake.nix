{
  description = "Home Manager configuration of tommy";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # nvim = {
  #   source = config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/dots/config/nvim";
  #   target = "${config.home.homeDirectory}/.config/nvim";
  # };
  outputs = { nixpkgs, home-manager, ... }:
    let
      common_modules = [ ./nix/home.nix ];
      user_name = "tommy";
      mk_config = config: name: {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dots/config/${name}";
        target = "${config.home.homeDirectory}/.config/${name}";
      };
    in {
      homeConfigurations = {
        "tommy@moebius" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = { inherit user_name mk_config; };
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = common_modules ++ [ ./nix/linux.nix ./nix/moebius.nix ];
        };
        "tommy@audron" = home-manager.lib.homeManagerConfiguration {
          specialArgs = { inherit user_name mk_config; };
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = common_modules ++ [ ./nix/linux.nix ./nix/audron.nix ];
        };
        mac = home-manager.lib.homeManagerConfiguration rec {
          specialArgs = { inherit user_name mk_config; };
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          modules = common_modules ++ [ ./nix/darwin.nix ];
        };
      };
    };
}
