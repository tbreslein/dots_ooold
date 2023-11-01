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
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    corectrl.enable = true;
  };
  networking.hostName = "moebius";
  users.users.tommy.packages = with pkgs; [
    (wineWowPackages.full.override {
      wineRelease = "staging";
      mingwSupport = true;
    })
    winetricks
    lutris
  ];
}
