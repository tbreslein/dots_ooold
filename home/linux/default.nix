{ config, pkgs, userConfig, ... }:

let
  gtkGruvboxPlus = import ./gtk-themes/gruvbox-plus.nix { inherit pkgs; };
  inherit (userConfig) colors;
in {
  home = {
    homeDirectory = "/home/${userConfig.name}";
    packages = with pkgs; [
      brave
      microsoft-edge
      discord
      telegram-desktop
      zathura

      imv
      mpv
      libnotify
      vlc
      playerctl
      pavucontrol
      nwg-look
      dunst

      (writeShellScriptBin "up-protonge" ''
        echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
        mkdir -p ~/tmp/proton-ge-custom
        pushd ~/tmp/proton-ge-custom
        curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)"
        curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)"
        if [[ $(sha512sum -c ./*.sha512sum) ]]; then
            mkdir -p ~/.steam/root/compatibilitytools.d
            tar -xf GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
            echo "All done :)"
        else
            echo "Error: protonge sha512sum did not match!"
        fi
        popd
        rm -fr ~/tmp/proton-ge-custom
      '')
    ];
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
    # syncthing.enable = true;
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
  };
}
