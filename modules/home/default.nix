{ config, lib, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.homeDefaults;
in {
  options.conf.homeDefaults = {
    system = with types; enum string [ "darwin" "linux" "wsl" ];
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    home = mkMerge [
      {
        username = "tommy";
        stateVersion = "23.05";
      }

      (mkIf (cfg.system == "darwin") {
        homeDirectory = lib.mkForce "/Users/tommy";
      })
      (mkIf (cfg.system == "linux" || cfg.system == "wsl") {
        homeDirectory = lib.mkForce "/home/tommy";
      })
    ];
    programs.home-manager.enable = true;
    services.syncthing.enable = true;
  };
}