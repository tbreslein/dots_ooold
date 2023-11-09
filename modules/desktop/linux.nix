{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  inherit (config) colors;
  gtkGruvboxPlus = import ./gtk-themes/gruvbox-plus.nix { inherit pkgs; };
  cfg = config.conf.desktop.linux;
in {
  options.conf.desktop.linux = {
    enable = lib.mkEnableOption "enable linux desktop apps";
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        brave
        microsoft-edge
        discord
        telegram-desktop
        zathura
        imv
        mpv
        libnotify
        vlc
        playerctl
        pavucontrol
        nwg-look
        dunst
      ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
    services = {
      dunst = {
        enable = true;
        settings = {
          global = {
            background = "#${colors.background}";
            foreground = "#${colors.foreground}";
            frame_color = "#${colors.accent}";
            font = "Noto Sans 11";
          };
          urgency_critical = { frame_color = "#${colors.brightRed}"; };
        };
      };
    };
    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Classic-Ice";
      };
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3";
      };
      iconTheme = {
        package = gtkGruvboxPlus;
        name = "GruvboxPlus";
      };
    };
  };
}
