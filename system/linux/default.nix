{ pkgs, lib, userConfig, ... }:

{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  sound.enable = true;
  hardware.opengl.enable = true;

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

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true;
      layout = "us,de";
      desktopManager.xterm.enable = false;
      displayManager = {
        sddm = {
          enable = userConfig.isWaylandWM;
          theme = "${import ./sddm-themes/sugar-dark.nix { inherit pkgs; }}";
          wayland.enable = userConfig.isWaylandWM;
        };
      };
      windowManager.dk.enable = userConfig.wm == "dk";
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

  # systemd = {
  #   user.services.polkit-kde-authentication-agent-1 = {
  #     description = "polkit-kde-authentication-agent-1";
  #     wantedBy = [ "graphical-session.target" ];
  #     wants = [ "graphical-session.target" ];
  #     after = [ "graphical-session.target" ];
  #     serviceConfig = {
  #       Type = "simple";
  #       ExecStart =
  #         "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
  #       Restart = "on-failure";
  #       RestartSec = 1;
  #       TimeoutStopSec = 10;
  #     };
  #   };
  # };

  programs = {
    dconf.enable = true;
    hyprland = {
      enable = userConfig.wm == "hyprland";
      xwayland.enable = true;
    };
  };
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM =
        if userConfig.wm == "hyprland" then "wayland:xcb" else "xcb";
    };
    systemPackages = with pkgs;
      (if userConfig.isWaylandWM then [
        libsForQt5.qt5.qtquickcontrols2
        libsForQt5.qt5.qtgraphicaleffects
      ] else
        [ picom-next ]);
  };
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };

  xdg.portal = {
    enable = userConfig.isWaylandWM;
    extraPortals = lib.mkIf (userConfig.wm == "hyprland")
      [ pkgs.xdg-desktop-portal-hyprland ];
  };

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "qwert";
    shell = pkgs.zsh;
  };

  system.stateVersion = "23.05";
}
