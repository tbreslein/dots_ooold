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
        source = ./dk;
        target = "${config.home.homeDirectory}/.config/dk";
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
