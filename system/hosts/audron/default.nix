{ userConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot = {
    initrd.luks.devices."luks-f82f08c3-4d51-4a0e-a78d-3d3ace234663".device =
      "/dev/disk/by-uuid/f82f08c3-4d51-4a0e-a78d-3d3ace234663";
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  networking.hostName = "audron";
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = userConfig.name;
  };
}