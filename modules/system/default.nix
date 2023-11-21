{ config, lib, pkgs, userName, ... }:
let
  inherit (lib) mkMerge mkOption types;
  cfg = config.conf.systemDefaults;
in {
  options.conf.systemDefaults = {
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [ vim coreutils wget curl unzip git killall ];
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 1w";
      };
      settings = {
        trusted-users = [ userName ];
        substituters = [ "https://cachix.cachix.org" ];
        trusted-public-keys = [
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        ];
      };
    };
    environment = {
      systemPackages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
      pathsToLink = [ "/share/bash-completion" ];
    };

    programs = {
      zsh.enable = true;
      bash.enable = true;
    };

    time.timeZone = "Europe/Berlin";
  };
}
