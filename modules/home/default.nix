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
        shellAliases = {
          v = "vim";
          g = "git";
          gs = "git status";
          gl = "git pull";
          gp = "git push origin";
          gpu = "git push --set-upstream";
          gpf = "git push --force-with-lease";
          gsw = "git switch";
          gb = "git branch";
          gco = "git checkout";
          ga = "git add";
          gaa = "git add .";
          gc = "git commit";
          gca = "git commit -a";
          gcam = "git commit --amend";
          gcaam = "git commit -a --amend";
          grm = "git rm";
          gmv = "git mv";
          gr = "git rebase";
          grc = "git rebase --continue";
          gra = "git rebase --abort";
        };
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
