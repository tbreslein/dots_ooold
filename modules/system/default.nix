{ config, lib, pkgs, ... }:
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
        trusted-users = [ "tommy" ];
        substituters = [ "https://cachix.cachix.org" ];
        trusted-public-keys = [
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        ];
      };
    };
    environment.systemPackages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
    programs.zsh.enable = true;
    time.timeZone = "Europe/Berlin";
  };
}
