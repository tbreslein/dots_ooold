{ config, pkgs, userConfig, ... }:
let inherit (userConfig) colors;
in {
  home = {
    packages = with pkgs; [
      dmenu
      arandr
      feh
      polybar
      flameshot
      gammastep
      sxhkd
      xclip
      xsel
    ];

    file = {
      dk = {
        executable = true;
        # this restart currently doesn't work, it just doesn't do anything.
        # probably because this call doesn't actually interact with the running
        # dk session?
        onChange = "${pkgs.dk}/bin/dkcmd restart";
        target = "${config.home.homeDirectory}/.config/dk/dkrc";
        text = ''
          #!/usr/bin/env sh
          logfile="$HOME/.dkrc.log"
          [ -d "$HOME/.local/share/xorg" ] && logfile="$HOME/.local/share/xorg/dkrc.log"
          : >"$logfile"

          if [ "$(cat /etc/hostname)" = "moebius" ]; then
              xrandr --output DisplayPort-2 --mode 3440x1440 --rate 120
          fi

          pgrep -f "$(which dunst)" >/dev/null || dunst &
          pgrep -x sxhkd >/dev/null || sxhkd &
          pgrep -x picom >/dev/null || picom -b --experimental-backends
          pgreg -f "$(which gammastep)" >/dev/null || gammastep -l 54.0:10.0 &
          feh --bg-fill /home/tommy/dots/wallpapers/moebius.jpg

          /home/tommy/.config/polybar/launch.sh

          if [ "$(cat /etc/hostname)" = "moebius" ]; then
              xrandr --output DisplayPort-2 --mode 3440x1440 --rate 120
          fi

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
        source = ./polybar;
        target = "${config.home.homeDirectory}/.config/polybar";
      };
    };
  };

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
  };
}
