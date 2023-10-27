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
  networking.hostName = "moebius";
  environment = {
    systemPackages = with pkgs; [
      steam
      (lutris.override { extraPkgs = pkgs: [ wineWowPackages.waylandFull ]; })
    ];
  };
}
