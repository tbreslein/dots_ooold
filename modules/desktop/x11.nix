{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  inherit (config) colors;
  cfg = config.conf.desktop.x11;
in {
  options.conf.desktop.x11 = {
    enable = lib.mkEnableOption "enable x11 config";
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        dmenu
        arandr
        feh
        polybar
        flameshot
        redshift
        sxhkd
        xclip
        xsel
      ];
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
      file = {
        dk = {
          executable = true;
          # this restart currently doesn't work, it just doesn't do anything.
          # probably because this call doesn't actually interact with the running
          # dk session?
          onChange =
            "DKSOCK=$(find /tmp -maxdepth 1 -name 'dk__*.socket') ${pkgs.dk}/bin/dkcmd restart";
          target = "${config.home.homeDirectory}/.config/dk/dkrc";
          text = ''
            #!/usr/bin/env sh
            logfile="${config.home.homeDirectory}/.dkrc.log"
            [ -d "${config.home.homeDirectory}/.local/share/xorg" ] && logfile="${config.home.homeDirectory}/.local/share/xorg/dkrc.log"
            : >"$logfile"

            autorandr -c
            pgrep -f "$(which dunst)" >/dev/null || dunst &
            pgrep -x sxhkd >/dev/null || sxhkd &
            pgrep -x picom >/dev/null || picom -b --experimental-backends
            pgreg -f "$(which redshift)" >/dev/null || redshift -l 54.0:10.0 &

            feh --bg-fill ${config.home.homeDirectory}/dots/wallpapers/moebius.jpg

            ${config.home.homeDirectory}/.config/polybar/launch.bash

            {
                dkcmd set numws=6
                dkcmd set ws=1 name="dev"
                dkcmd set ws=2 name="web"
                dkcmd set ws=3 name="misc"
                dkcmd set ws=4 name="launchers"
                dkcmd set ws=5 name="games"
                dkcmd set ws=6 name="comms"

                # default layout
                dkcmd set ws=_ apply layout=rtile master=1 stack=4 gap=8 msplit=0.66

                dkcmd set focus_open=true focus_mouse=true
                dkcmd set mouse mod=super move=button1 resize=button3

                dkcmd set border width=2 outer_width=0 \
                    colour \
                    focus='#${colors.accent}' \
                    unfocus='#${colors.background}' \
                    urgent='#${colors.brightRed}'

                dkcmd rule class="^gimp$" ws=3
                dkcmd rule class="^(pavucontrol|transmission-gtk|lxappearance)$" float=true
                dkcmd rule title="^(Picture in picture|Picture-in-picture)$" float=true stick=true
                dkcmd rule class="^(steam|lutris|battle.net.exe)$" float=true ws=4
                dkcmd rule title="^(Wine System Tray)$" float=true ws=4 x=3250 y=1350

                dkcmd rule apply '*' # reapplies rules on dk restart
            } >>"$logfile" 2>&1

            if grep -q 'error:' "$logfile"; then
                hash notify-send && notify-send -t 0 -u critical "dkrc has errors" \
                    "$(awk '/error:/ {sub(/^error: /, ""); gsub(/</, "\<"); print)' "$logfile")"
                exit 1
            fi

            exit 0
          '';
        };
        polybar = {
          executable = true;
          target = "${config.home.homeDirectory}/.config/polybar/launch.bash";
          text = ''
            #!/usr/bin/env bash
            killall -q polybar
            polybar main 2>&1 | tee -a /tmp/polybar.main.log &
            disown
          '';
        };
      };
    };

    programs.autorandr.enable = true;
    services = {
      autorandr.enable = true;
      picom = {
        enable = true;
        settings = {
          backend = "glx";
          blur = {
            method = "gaussian";
            size = 10;
            deviation = 5.0;
          };
          corner-radius = 7;
          fading = true;
          fade-in-step = 2.8e-2;
          fade-out-step = 2.8e-2;
        };
      };

      sxhkd = {
        enable = true;
        keybindings = {
          "super + Escape" = "pkill -USR1 -x sxhkd";
          "super + Return" = "alacritty";
          "super + @space" =
            "dmenu_run -i -fn 'Hack:size=19' -nb '#${colors.background}' -nf '#${colors.foreground}' -sb '#${colors.brightBlack}' -sf '#${colors.accent}'";
          "super + alt + b" = "brave";
          "XF86AudioMute" = "wpctl set-mute @DEFAULT_SINK@ toggle";
          "{XF86AudioRaiseVolume,XF86AudioLowerVolume}" =
            "wpctl set-volume @DEFAULT_SINK@ 5%{+,-}";
          "{XF86AudioPlay,XF86AudioNext,XF86AudioPrev}" =
            "playerctl {play-pause,next,prev}";
          "{XF86MonBrightnessUp,XF86MonBrightnessDown}" = "light -{A,U} 5";

          # dk
          "super + shift + ctrl + {q,r}" = "dkcmd {exit,restart}";
          "super + shift + ctrl + r" = "$HOME/.config/dk/dkrc";

          # window control
          "super + shift + {j,k}" = "dkcmd win focus {next,prev}";
          "super + ctrl + {j,k}" = "dkcmd win mvstack {down,up}";
          "super + ctrl + {q,g}" = "dkcmd win {kill,swap}";
          "super + {shift,ctrl} + f" = "dkcmd win {fakefull,full}";
          "super + {shift,ctrl} + v" = "dkcmd win {stick,float}";
          "super + alt + {h,j,k,l}" =
            "dkcmd win resize {x=-20,y=+20,y=-20,x=+20}";

          # workspaces / monitors
          "super + {_,ctrl + }{1-6}" = "dkcmd ws {view,send} {1-6}";
          "super + {shift,ctrl} + {comma,period}" =
            "dkcmd mon {view,send} {prev,next}";
          "super + alt + {t,r,m,v}" = "dkcmd set layout {tile,rtile,mono,none}";
        };
      };

      polybar = {
        enable = true;
        script = "polybar main &"; # irrelevant, isn't used
        config = {
          settings = {
            screenchange-reload = true;
            pseudo-transparency = true;
          };
          "bar/main" = {
            width = "100%";
            height = "3%";
            radius = 6;
            background = "#${colors.background}";
            foreground = "#${colors.foreground}";
            line-size = "3pt";
            border-size = "4pt";
            border-color = "#00000000";
            padding-left = 0;
            padding-right = 1;
            module-margin = 1;
            separator = "|";
            separator-foreground = "#${colors.black}";
            font-0 = "Hack Nerd Font; 2";
            modules-left = "workspaces";
            modules-center = "date";
            modules-right = "xkeyboard memory cpu wlan eth";
            cursor-click = "pointer";
            enable-ipc = true;
            tray-spacing = "16pt";
            tray-position = "right";
          };
          "module/workspaces" = {
            type = "internal/xworkspaces";
            pin-workspaces = false;
            pin-click = true;
            label-active = "%name%";
            label-active-underline = "#${colors.accent}";
            label-active-background = "#${colors.black}";
            label-active-padding = 1;
            label-occupied = "%name%";
            label-occupied-background = "#${colors.black}";
            label-occupied-padding = 1;
            label-urgent = "%name%";
            label-urgent-background = "#${colors.brightRed}";
            label-urgent-padding = 1;
            label-empty = "%name%";
            label-empty-background = "#${colors.background}";
            label-empty-padding = 1;
          };
          "module/date" = {
            type = "internal/date";
            interval = 10;
            date = "%H:%M";
            date-alt = "%d-%m-%Y %H:%M:%S";
            label = "%date%";
            label-foreground = "#${colors.accent}";
          };
          "module/xkeyboard" = {
            type = "internal/xkeyboard";
            blacklist-0 = "num lock";
            label-layout = "%layout%";
            label-layout-foreground = "#${colors.accent}";
            label-indicator-padding = 2;
            label-indicator-margin = 1;
            label-indicator-background = "#${colors.background}";
            label-indicator-foreground = "#${colors.foreground}";
          };
          "module/memory" = {
            type = "internal/memory";
            interval = 2;
            format-prefix = "RAM ";
            format-prefix-foreground = "#${colors.accent}";
            label = "%percentage_used:2%%";
          };
          "module/cpu" = {
            type = "internal/cpu";
            interval = 2;
            format-prefix = "CPU ";
            format-prefix-foreground = "#${colors.accent}";
            label = "%percentage:2%%";
          };
          "network-base" = {
            type = "internal/network";
            interval = 5;
            format-connected = "<label-connected>";
            format-disconnected = "<label-disconnected>";
            label-disconnected =
              "%{F#${colors.accent}}%ifname%%{F#${colors.brightRed}} disconnected";
          };
          "module/wlan" = {
            "inherit" = "network-base";
            interface-type = "wireless";
            label-connected =
              "%{F#${colors.accent}}%ifname%%{F-} %essis% %local_ip%";
          };
          "module/eth" = {
            "inherit" = "network-base";
            interface-type = "wired";
            label-connected = "%{F#${colors.accent}}%ifname%%{F-} %local_ip%";
          };
        };
      };
    };
  };
}
