{ config, lib, userName, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.homeDefaults;
in {
  options.conf.homeDefaults = {
    system = mkOption { type = with types; enum [ "darwin" "linux" "wsl" ]; };
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    home = mkMerge [
      {
        username = userName;
        stateVersion = "23.05";
        packages = mkMerge [ cfg.extraPkgs cfg.defaultPkgs ];
      }

      (mkIf (cfg.system == "darwin") {
        homeDirectory = lib.mkForce "/Users/${userName}";
      })
      (mkIf (cfg.system == "linux" || cfg.system == "wsl") {
        homeDirectory = lib.mkForce "/home/${userName}";
      })
    ];
    programs.home-manager.enable = true;
    services.syncthing.enable = true;
  };
}
