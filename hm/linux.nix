{ config, pkgs, user_name, mk_config, ... }: {
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
    ];

    file = {
      alacritty = mk_config config "alacritty";
      up = {
        executable = true;
        target = "${config.home.homeDirectory}/.local/bin/up";
        text = ''
          #!/usr/bin/env bash
          source ~/.bashrc
          pushd ${config.home.homeDirectory}/dots
          [[ -n $(git status -s) ]] && echo "git tree is dirty" && popd && return 1
          function up-nix {
              # nix-collect-garbage -d
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
          case "$1" in
            nix) up-nix;;
            nvim) up-nvim;;
            all) up-all;;
          esac
          popd
        '';
      };
    };
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      historyFile = "${config.home.homeDirectory}/.bash_histoy";
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
}
