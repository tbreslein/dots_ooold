{ config, pkgs, userConfig, ... }:
let gtkGruvboxPlus = import ./gtk-themes/gruvbox-plus.nix { inherit pkgs; };
in {
  fonts.fontconfig.enable = true;
  home = {
    homeDirectory = "/home/${userConfig.name}";

    packages = [
      # desktop
      pkgs.brave
      pkgs.microsoft-edge
      pkgs.discord
      pkgs.telegram-desktop
      pkgs.vlc

      # fonts
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji

      # shell scripts
      (pkgs.writeShellScriptBin "up" ''
        source ~/.bashrc
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
      pkgs.playerctl

      # desktop
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

      # apps
      pkgs.zathura
      pkgs.nwg-look
      pkgs.pavucontrol
    ] else if userConfig.isXWM then [
      pkgs.dmenu
      pkgs.feh
      pkgs.zathura
      pkgs.pavucontrol
      pkgs.nitrogen
      pkgs.polybar
      pkgs.flameshot
      pkgs.gammastep
      pkgs.sxhkd
    ] else
      [ ]);

    file = {
      alacritty = userConfig.linkConfig config "alacritty";
    } // (if userConfig.isWaylandWM then {
      hypr = userConfig.linkConfig config "hypr";
      tofi = userConfig.linkConfig config "tofi";
      waybar = userConfig.linkConfig config "waybar";
    } else if userConfig.wm == "bspwm" then {
      bspwm = userConfig.linkConfig config "bspwm";
      sxhkd = userConfig.linkConfig config "sxhkd";
      polybar = userConfig.linkConfig config "polybar";
    } else if userConfig.wm == "dk" then {
      dk = userConfig.linkConfig config "dk";
      # sxhkd = userConfig.linkConfig config "sxhkd";
      polybar = userConfig.linkConfig config "polybar";
    } else
      { });
  };

  programs = {
    bash = {
      enable = userConfig.linuxShell == "bash";
      enableCompletion = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      historyFile = "${config.home.homeDirectory}/.bash_history";
      shellOptions = [ "histappend" "globstar" "checkwinsize" ];
      bashrcExtra = ''
        # make less more friendly for non-text input files, see lesspipe(1)
        [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      '';
      profileExtra = ''
        # if running bash
        if [ -n "$BASH_VERSION" ]; then
            # include .bashrc if it exists
            if [ -f "$HOME/.bashrc" ]; then
                . "$HOME/.bashrc"
            fi
        fi

        # set PATH so it includes user's private bin if it exists
        if [ -d "$HOME/bin" ]; then
            PATH="$HOME/bin:$PATH"
        fi

        # set PATH so it includes user's private bin if it exists
        if [ -d "$HOME/.local/bin" ]; then
            PATH="$HOME/.local/bin:$PATH"
        fi
      '';
    };

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
    mako = {
      enable = userConfig.isWaylandWM;
      borderRadius = 5;
      backgroundColor = "#32302fff";
      borderColor = "#d8a657ff";
      textColor = "#ddc7a1ff";
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
  };
}
