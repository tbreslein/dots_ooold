{ config, pkgs, user_name, ... }: {
  fonts.fontconfig.enable = true;
  home = {
    homeDirectory = "/home/${user_name}";
    packages = [
      # desktop
      pkgs.brave
      pkgs.dmenu
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    ];
    file = {
      alacritty = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dots/config/alacritty";
        target = "${config.home.homeDirectory}/.config/alacritty";
      };
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
}
