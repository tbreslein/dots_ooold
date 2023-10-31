{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./moebius-hardware.nix ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
  };
  # environment = {
  #   systemPackages = with pkgs;
  #     [
  #       # (lutris.override {
  #       #   extraPkgs = pkgs: [
  #       #     (wineWowPackages.full.override {
  #       #       wineRelease = "staging";
  #       #       mingwSupport = true;
  #       #     })
  #       #     winetricks
  #       #   ];
  #       # })
  #     ];
  #   sessionVariables = {
  #     WINEARCH = "win64";
  #     WINEPREFIX = "/home/tommy/.wine";
  #   };
  # };
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    corectrl.enable = true;
  };
  networking.hostName = "moebius";
}
