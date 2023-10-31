{ config, pkgs, userConfig, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "tommy" ];
      substituters = [ "https://cachix.cachix.org" ];
      trusted-public-keys =
        [ "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=" ];
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
    extraHosts = ''
      192.168.0.91 moebius
      192.168.0.90 vorador
    '';
  };
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
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
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services = {
    xserver = {
      layout = "us,de";
      enable = true;
      displayManager.sddm = {
        enable = true;
        theme = "${import ./sddm-themes/sugar-dark.nix { inherit pkgs; }}";
        wayland.enable = userConfig.isWaylandWM || userConfig.wm == "plasma";
      };
    };
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };

  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  programs.hyprland = {
    enable = userConfig.isWaylandWM;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = if userConfig.wm == "hyprland" then
      [ pkgs.xdg-desktop-portal-hyprland ]
    else
      [ ];
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM =
        if userConfig.wm == "hyprland" then "wayland:xcb" else "xcb";
    };
    systemPackages = with pkgs; [
      vim
      wget
      curl
      unzip
      git
      killall

      # for sddm themeing
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtgraphicaleffects
    ];
  };

  sound.enable = true;
  hardware.opengl.enable = true;

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "qwert";
    packages = with pkgs; [ alacritty ];
  };

  system.stateVersion = "23.05";
}
