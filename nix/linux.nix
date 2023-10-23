{ config, pkgs, user_name, mk_config, ... }:
let
  mk_config_home = config: name: {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dots/config/${name}";
    target = "${config.home.homeDirectory}/${name}";
  };
in {
  fonts.fontconfig.enable = true;
  home = {
    homeDirectory = "/home/${user_name}";

    packages = [
      # desktop
      pkgs.brave
      pkgs.discord
      pkgs.dmenu

      # fonts
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji
    ];

    file = {
      bashrc = mk_config_home config ".bashrc";
      profile = mk_config_home config ".profile";
      # bashrc = {
      #   source = config.lib.file.mkOutOfStoreSymlink
      #     "${config.home.homeDirectory}/dots/config/bash/.bashrc";
      #   target = "${config.home.homeDirectory}/.bashrc";
      # };

      # profile = {
      #   source = config.lib.file.mkOutOfStoreSymlink
      #     "${config.home.homeDirectory}/dots/config/bash/.profile";
      #   target = "${config.home.homeDirectory}/.profile";
      # };

      alacritty = mk_config config "alacritty";
      awesome = mk_config config "awesome";

      up = {
        executable = true;
        target = "${config.home.homeDirectory}/.local/bin/up";
        text = ''
          #!/usr/bin/env bash
          source ~/.bashrc
          sudo apt update && sudo apt upgrade
          pushd ${config.home.homeDirectory}/dots
          home-manager switch --impure --flake .
          nvim --headless "+Lazy! sync" +qa
          popd
        '';
      };
    };
  };

  gtk.cursorTheme.package = pkgs.vanilla-dmz;
}
