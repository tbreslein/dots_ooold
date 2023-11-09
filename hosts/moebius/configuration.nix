{ ... }:

{
  imports = [ ./hardware-configuration.nix ];
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
      configurationLimit = 10;
    };
  };
  networking.hostName = "moebius";

  desktop = {
    enable = true;
    enableWayland = true;
    enableX11 = false;
  };
  systemDefaults = {
    system = "linux";
    enableGaming = true;
  };
}
