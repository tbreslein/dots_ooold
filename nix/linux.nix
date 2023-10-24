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
      pkgs.dmenu
      pkgs.feh
      pkgs.flameshot
      pkgs.gammastep
      pkgs.networkmanagerapplet
      pkgs.pasystray
      pkgs.picom
      pkgs.telegram-desktop
      pkgs.vlc
      pkgs.zathura

      # fonts
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji
    ];

    file = {
      alacritty = mk_config config "alacritty";
      awesome = mk_config config "awesome";
      xinitrc = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dots/config/xinitrc";
        target = "${config.home.homeDirectory}/.xinitrc";
      };
    };
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      historyFile = "${config.home.homeDirectory}/.bash_histoy";
      shellOptions = [ "histappend" "globstar" "checkwinsize" "vi" ];
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

        if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
            exec startx
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
  #   theme = {
  #     name = "Gruvbox-Dark";
  #     package = pkgs.gruvbox-gtk-theme;
  #   };
  #   iconTheme.name = "Gruvbox-Dark";
  #   # cursorTheme.package = pkgs.vanilla-dmz;
  #   cursorTheme.name = "Gruvbox-cursors";
  # };

  services = {
    gammastep = {
      enable = true;
      latitude = 54.323334;
      longitude = 10.139444;
    };
  };

  targets.genericLinux.enable = true;
}
