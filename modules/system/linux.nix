{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.conf.systemDefaults;
in {
  options.conf.systemDefaults = {
    enableGaming = lib.mkEnableOption "enable gaming stuff";
  };

  config = mkMerge [
    {
      nix = {
        optimise.automatic = true;
        gc.dates = "weekly";
        settings.experimental-features = [ "nix-command" "flakes" ];
      };

      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        extraHosts = ''
          192.168.0.92 audron
          192.168.0.91 moebius
          192.168.0.90 vorador
        '';
      };
      security = {
        rtkit.enable = true;
        polkit.enable = true;
      };
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      i18n.defaultLocale = "en_US.UTF-8";

      users.users.tommy = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        initialPassword = "qwert";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keyFiles = ./id_rsa.pub;
      };

      system.stateVersion = "23.05";
    }

    (mkIf cfg.enableGaming {
      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
        };
        corectrl.enable = true;
        gamemode.enable = true;
      };
      security.polkit.extraConfig = ''
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
    })
  ];
}
