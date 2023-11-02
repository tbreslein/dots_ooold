{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "tommy" ];
      substituters = [ "https://cachix.cachix.org" ];
      trusted-public-keys =
        [ "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=" ];
    };
  };

  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [ bash dash ksh tcsh zsh ];
    systemPackages = with pkgs; [
      alacritty
      vim
      coreutils
      wget
      curl
      unzip
      git
      killall
    ];
  };

  time.timeZone = "Europe/Berlin";
}
