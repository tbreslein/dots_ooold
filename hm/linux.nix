{ config, pkgs, user_name, mk_config, ... }:
let gruvboxPlus = import ./gruvbox-plus.nix { inherit pkgs; };
in {
  fonts.fontconfig.enable = true;
  home = {
    homeDirectory = "/home/${user_name}";

    packages = [
      # cli
      pkgs.imv
      pkgs.mpv
      pkgs.pfetch-rs

      # desktop
      pkgs.brave
      pkgs.discord
      pkgs.telegram-desktop
      pkgs.vlc
      pkgs.zathura

      # wayland
      pkgs.waybar
      pkgs.eww
      pkgs.mako
      pkgs.wl-clipboard
      pkgs.swww
      pkgs.tofi

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
            nix flake update
            if [[ -n $(git status -s) ]]; then
                git add flake.lock && git commit -m "update flake.lock"
            fi
            sudo nixos-rebuild switch --flake .
        }
        function up-nvim {
            nvim --headless "+Lazy! sync" +qa
        }
        function up-all {
            up-nix
            up-nvim
        }

        if [[ -n $(git status -s) ]]; then
            echo "Error: git tree is dirty"
        else
            case "$1" in
              nix) up-nix;;
              nvim) up-nvim;;
              all) up-all;;
              *) echo "Error: unknown command";;
            esac
        fi
        popd
      '')
    ];

    file = {
      alacritty = mk_config config "alacritty";
      hypr = mk_config config "hypr";
    };
  };

  programs = {
    bash = {
      enable = true;
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
      package = gruvboxPlus;
      name = "GruvboxPlus";
    };
  };
}
