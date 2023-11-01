{ ... }:

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
}
