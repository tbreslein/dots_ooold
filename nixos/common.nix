{ pkgs, lib, userConfig, inputs, ... }: {
  imports = [ inputs.xremap-flake.nixosModules.default ];
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
    xremap = {
      userName = userConfig.name;
      # serviceMode = if userConfig.wm == "hyprland" then "user" else "system";
      serviceMode = "user";
      withHypr = userConfig.wm == "hyprland";
      withX11 = userConfig.isXWM;
      config = {
        modmap = [{
          name = "Global";
          remap = { "CapsLock" = "Esc"; };
        }];
        keymap = [{
          name = "apps";
          remap = {
            SUPER-SHIFT-j.launch =
              [ "${pkgs.dk}/bin/dkcmd" "win" "focus" "next" ];
            SUPER-SHIFT-k.launch =
              [ "${pkgs.dk}/bin/dkcmd" "win" "focus" "prev" ];
            SUPER-ALT-b.launch = [ "${pkgs.brave}/bin/brave" ];
            SUPER-space.launch = [
              "${pkgs.dmenu}/bin/dmenu_run"
              "-i"
              "-p"
              "dmenu_run"
              "-fn"
              "Hack:size=19"
              "-nb"
              "#${userConfig.colors.background}"
              "-nf"
              "#${userConfig.colors.foreground}"
              "-sb"
              "#${userConfig.colors.brightBlack}"
              "-sf"
              "#${userConfig.colors.accent}"
            ];
            SUPER-enter.launch = [ "${pkgs.alacritty}/bin/alacritty" ];
            PRINT.launch = [ "" ];
            PLAYPAUSE.launch =
              [ "${pkgs.playerctl}/bin/playerctl" "play-pause" ];
            NEXTSONG.launch = [ "${pkgs.playerctl}/bin/playerctl" "next" ];
            PREVIOUSSONG.launch =
              [ "${pkgs.playerctl}/bin/playerctl" "previous" ];
            BRIGHTNESSUP.launch = [ "${pkgs.light}/bin/light" "-A" "5" ];
            BRIGHTNESSDOWN.launch = [ "${pkgs.light}/bin/light" "-U" "5" ];
            MUTE.launch = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-mute"
              "@DEFAULT_SINK@"
              "toggle"
            ];
            VOLUMEUP.launch = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_SINK@"
              "5%+"
            ];
            VOLUMEDOWN.launch = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_SINK@"
              "5%-"
            ];
          };
        }];
      };
    };
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
    zsh.enable = true;
  };

  xdg.portal = {
    enable = userConfig.isWaylandWM;
    extraPortals = lib.mkIf (userConfig.wm == "hyprland")
      [ pkgs.xdg-desktop-portal-hyprland ];
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM =
        if userConfig.wm == "hyprland" then "wayland:xcb" else "xcb";
    };
    systemPackages = with pkgs;
      [ vim wget curl unzip git killall ] ++ (if userConfig.isWaylandWM then [

        # for sddm themeing
        libsForQt5.qt5.qtquickcontrols2
        libsForQt5.qt5.qtgraphicaleffects
      ] else
        [ picom-next ]);
  };

  sound.enable = true;
  hardware.opengl.enable = true;

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
    initialPassword = "qwert";
    packages = with pkgs; [ alacritty kitty ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "23.05";
}
