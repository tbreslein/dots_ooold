{ config, lib, pkgs, userName, overlays, ... }:
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
    nixpkgs = {
      config.allowUnfree = true;
      inherit overlays;
    };
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      settings = {
        trusted-users = [ userName ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://cachix.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        ];
      };
    };
    environment = {
      systemPackages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
      pathsToLink = [ "/share/bash-completion" ];
    };

    time.timeZone = "Europe/Berlin";
  };
}
