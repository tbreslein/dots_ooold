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
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    corectrl.enable = true;
    gamemode.enable = true;
  };
  security = {
    polkit = {
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if ((action.id == "org.corectrl.helper.init" ||
                 action.id == "org.corectrl.helperkiller.init") &&
                subject.local == true &&
                subject.active == true &&
                subject.isInGroup("wheel")) {
                    return polkit.Result.YES;
            }
        });
      '';
    };
  };

  networking.hostName = "moebius";
}
