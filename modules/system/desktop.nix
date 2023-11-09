{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.conf.desktop;
in {
  options.conf.desktop = {
    enable = mkEnableOption "enable nixos desktop stuff";
    defaultSystemPackages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [ alacritty ];
    };
    extraSystemPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    enableWayland = mkEnableOption "enable wayland stuff";
    enableX11 = mkEnableOption "enable x11 stuff";
  };

  config = mkIf cfg.enable {
    sound.enable = true;
    hardware.opengl.enable = true;

    services = {
      xserver = {
        enable = true;
        layout = "us,de";
        desktopManager.xterm.enable = false;
        displayManager = {
          sddm = {
            enable = true;
            theme = "${import ./sddm-themes/sugar-dark.nix { inherit pkgs; }}";
            wayland = mkIf cfg.enableWayland { enable = true; };
          };
        };
        windowManager.dk = mkIf cfg.enableX11 { enable = true; };
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

    programs = {
      dconf.enable = true;
      hyprland = mkIf cfg.enableWayland {
        enable = true;
        xwayland.enable = true;
      };
    };
    environment = {
      sessionVariables = mkIf cfg.enableWayland {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland:xcb";
      };
      systemPackages = mkMerge [
        cfg.defaultSystemPackages
        cfg.extraSystemPackages
        (mkIf cfg.enableWayland
          (with pkgs.libsForQt5.qt5; [ qtquickcontrols2 qtgraphicaleffects ]))
        (mkIf cfg.enableX11 [ pkgs.picom-next ])
      ];
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

    xdg.portal = cfg.enableWayland {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };
}
