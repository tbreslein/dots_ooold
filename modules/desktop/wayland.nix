{ config, lib, pkgs, colors, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.desktop.wayland;
in {
  options.conf.desktop.wayland = {
    enable = lib.mkEnableOption "enable wayland config";
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        waybar
        wl-clipboard
        swaybg
        kanshi
        bemenu
        wdisplays
        wlsunset
        grim
        slurp
      ];
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
      file = {
        electron13-flags = {
          text = ''
            --enable-features=UseOzonePlatform
            --ozone-platform=wayland
          '';
          target =
            "${config.home.homeDirectory}/.config/electron13/electron13-flags.conf";
        };
        electron-flags = {
          text = ''
            --ozone-platform-hint=auto
            --enable-webrtc-pipewire-capturer
            --gtk-version=4
          '';
          target =
            "${config.home.homeDirectory}/.config/electron/electron-flags.conf";
        };
      };
    };
    services = {
      kanshi.enable = true;
      wlsunset = {
        enable = true;
        latitude = "54.2";
        longitude = "10.5";
      };
    };

    programs.ags = {
      enable = true;
      configDir = ./ags;
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "battery"
            "separator"
            "wireplumber"
            "separator"
            "network"
            "separator"
            "tray"
          ];
          clock.format = "{:%H:%M}";
          "custom/separator".format = " | ";
          battery = {
            states = {
              full = 99;
              good = 98;
              normal = 98;
              warning = 20;
              critical = 20;
            };
            format = "{icon}   {capacity}%";
            format-good = "{icon}   {capacity}%";
            format-full = "   {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            interval = 30;
          };
          network = {
            format-ethernet = "󰈀 ";
            format-wifi = "  ";
            format-disconnected = " ";
          };
          wireplumber = {
            format = "{icon} {volume}%";
            format-bluetooth = " {volume}%";
            format-muted = "󰝟 ";
            max-volume = 150.0;
            format-icons = { default = [ "" ]; };
          };
        };
      };
      style = ''
        * {
          font-family: "Hack Nerd Font";
          font-size: 18px;
        }

        window#waybar {
          background-color: #${colors.background};
          color: #${colors.foreground};
        }

        .modules-left {
          background-color: #${colors.background};
          padding: 0px 0px 0px 0px;
        }

        .modules-right {
          background-color: #${colors.background};
          padding: 0px 5px 0px 0px;
        }

        #workspaces button {
          padding: 0px 11px 0px 11px;
          min-width: 1px;
          color: #${colors.foreground};
        }

        #workspaces button.active {
          padding: 0px 11px 0px 11px;
          background-color: #${colors.black};
          color: #${colors.accent};
        }

        #window {
          background-color: #${colors.background};
          padding: 0px 10px 0px 10px;
        }

        #custom-separator,
        #network,
        #temperature,
        #backlight,
        #pulseudio,
        #battery {
          padding: 0px 15px 0px 15px;
        }

        #custom-separator {
            color: #${colors.black};
        }

        #clock {
          margin: 0px 15px 0px 15px;
        }

        #tray {
          padding: 0px 8px 0px 5px;
          margin: 0px 5px 0px 5px;
        }

        #battery.critical {
          color: #${colors.brightRed};
        }

        #network.disconnected {
          color: #${colors.brightRed};
        }
      '';
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        exec-once = [
          "waybar"
          "mako"
          "swaybg -m fill -i /home/tommy/syncthing/personal/wallpapers/gruvbox/lofi-cafe_gray.jpg"
        ];
        exec = [ "kanshi" "wlsunset" ];
        general = {
          border_size = 2;
          "col.active_border" = "rgba(${colors.accent}ee)";
          "col.inactive_border" = "rgba(${colors.black}ee)";
          layout = "master";
        };
        input = {
          repeat_rate = 35;
          repeat_delay = 300;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };
        decoration.rounding = 5;
        master.orientation = "right";
        windowrulev2 = [
          "float,title:^(Picture(.)in(.)picture)$"
          "pin,title:^(Picture(.)in(.)picture)$"
          "float,class:^(steam)$,title:^(Friends list)$"
          "float,class:^(steam)$,title:^(Steam Settings)$"
          "workspace 3,class:^(steam)$"
          "workspace 3,class:^(lutris)$"
          "workspace 3,title:^(Wine System Tray)$"
          "workspace 4,class:^(battle.net.exe)$"
        ];
        "$mod" = "SUPER";
        bind = [
          "$mod, t, exec, alacritty"
          "$mod, b, exec, brave"
          "$mod, Space, exec, bemenu-run -i -c -p '' -W 0.3 -l 20 --fn 'Hack 18' --fb '##${colors.black}' --ff '##${colors.foreground}' --nb '##${colors.background}' --nf '##${colors.foreground}' --ab '##${colors.background}' --af '##${colors.foreground}' --hb '##${colors.background}' --hf '##${colors.accent}'"
          "$mod, q, killactive,"
          "$mod ALT, q, exit,"
          "$mod, f, fullscreen, 1"
          "$mod ALT, f, fullscreen, 0"
          "$mod ALT, v, togglefloating,"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
          "$mod, p, exec, grim -g '$(slurp)' ~/Pictures/$(date +'%s_grim.png')"
          "$mod ALT, p, exec, grim -g '$(slurp)' - | wl-copy"
          "$mod, o, exec, grim ~/Pictures/$(date +'%s_grim.png')"
          "$mod ALT, o, exec, grim - | wl-copy"

          "$mod, j, cyclenext,"
          "$mod, k, cyclenext, prev"
          "$mod CTRL, h, swapwindow, l"
          "$mod CTRL, j, swapwindow, d"
          "$mod CTRL, k, swapwindow, u"
          "$mod CTRL, l, swapwindow, r"
          "$mod, Tab, cyclenext,"
          "$mod, Tab, bringactivetotop,"

          "$mod ALT, h, resizeactive, -10,0"
          "$mod ALT, j, resizeactive, 0,10"
          "$mod ALT, k, resizeactive, ,-10"
          "$mod ALT, l, resizeactive, 10,0"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod ALT, 1, movetoworkspace, 1"
          "$mod ALT, 2, movetoworkspace, 2"
          "$mod ALT, 3, movetoworkspace, 3"
          "$mod ALT, 4, movetoworkspace, 4"
          "$mod ALT, 5, movetoworkspace, 5"
        ];
        bindm =
          [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      };
    };
  };
}
