{ config, pkgs, userConfig, ... }:
let
  gtkGruvboxPlus = import ./gtk-themes/gruvbox-plus.nix { inherit pkgs; };
  inherit (userConfig) colors;
in {
  fonts.fontconfig.enable = true;
  home = {
    homeDirectory = "/home/${userConfig.name}";

    packages = [
      pkgs.playerctl
      pkgs.brave
      pkgs.microsoft-edge
      pkgs.discord
      pkgs.telegram-desktop
      pkgs.vlc
      pkgs.zathura
      pkgs.pavucontrol
      pkgs.nwg-look

      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji

      (pkgs.writeShellScriptBin "up" ''
        pushd ${config.home.homeDirectory}/dots

        function up-nix {
            echo -e "\n\033[1;32m[ up-nix ]\033[0m"
            nix flake update
            if [[ -n $(git status -s) ]]; then
                git add flake.lock && git commit -m "update flake.lock"
            fi
            sudo nixos-rebuild switch --flake .
        }

        function up-nvim {
            echo -e "\n\033[1;32m[ up-nvim ]\033[0m"
            nvim --headless "+Lazy! sync" +qa
        }

        function up-protonge {
            echo -e "\n\033[1;32m[ up-protonge ]\033[0m"
            mkdir -p ~/tmp/proton-ge-custom
            cd ~/tmp/proton-ge-custom
            curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)"
            curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)"
            if [[ $(sha512sum -c ./*.sha512sum) ]]; then
                mkdir -p ~/.steam/root/compatibilitytools.d
                tar -xf GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
                echo "All done :)"
            else
                echo "Error: protonge sha512sum did not match!"
            fi
            rm -fr ~/tmp/proton-ge-custom
        }

        function up-all {
            up-nix
            up-nvim
            up-protonge
        }

        if [[ -n $(git status -s) ]]; then
            echo "Error: git tree is dirty"
        else
            case "$1" in
              nix) up-nix;;
              nvim) up-nvim;;
              pge) up-protonge;;
              all) up-all;;
              *) echo "Error: unknown command";;
            esac
        fi
        popd
      '')
    ] ++ (if userConfig.isWaylandWM then [
      # cli
      pkgs.imv
      pkgs.mpv
      pkgs.waybar
      pkgs.eww
      pkgs.mako
      pkgs.libnotify
      pkgs.wl-clipboard
      pkgs.swww
      pkgs.kanshi
      pkgs.tofi
      pkgs.wdisplays
      pkgs.wlsunset
      pkgs.grim
      pkgs.slurp
    ] else if userConfig.isXWM then [
      pkgs.libnotify
      pkgs.dmenu
      pkgs.arandr
      pkgs.feh
      pkgs.zathura
      pkgs.polybar
      pkgs.flameshot
      pkgs.gammastep
      pkgs.sxhkd
      pkgs.xclip
      pkgs.xsel
    ] else
      [ ]);

    file = { } // (if userConfig.isWaylandWM then {
      hypr = userConfig.linkConfig config "hypr";
      tofi = userConfig.linkConfig config "tofi";
      waybar = userConfig.linkConfig config "waybar";
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
    } else if userConfig.wm == "dk" then {
      dk = userConfig.linkConfig config "dk";
      polybar = userConfig.linkConfig config "polybar";
    } else
      { });
  };

  programs = {
    alacritty.settings.font.size = 12;
    git = {
      userName = "Tommy Breslein";
      userEmail = "tommy.breslein@protonmail.com";
    };
  };

  # gtk = {
  #   enable = true;
  #   cursorTheme = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Classic-Ice";
  #   };
  #   theme = {
  #     package = pkgs.adw-gtk3;
  #     name = "adw-gtk3";
  #   };
  #   iconTheme = {
  #     package = gtkGruvboxPlus;
  #     name = "GruvboxPlus";
  #   };
  # };

  services = {
    kanshi = { enable = userConfig.isWaylandWM; };
    dunst = {
      enable = userConfig.isXWM;
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
    mako = {
      enable = userConfig.isWaylandWM;
      borderRadius = 5;
      backgroundColor = "#${colors.background}";
      textColor = "#${colors.foreground}";
      borderColor = "#${colors.accent}";
      defaultTimeout = 20;
    };
    wlsunset = {
      enable = userConfig.isWaylandWM;
      latitude = "54.2";
      longitude = "10.5";
    };
    syncthing.enable = true;

    picom = {
      enable = userConfig.isXWM;
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
      enable = userConfig.isXWM;
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
