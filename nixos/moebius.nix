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
  environment = { systemPackages = with pkgs; [ lutris corectrl ]; };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  networking.hostName = "moebius";
}
