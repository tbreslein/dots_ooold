{ config, pkgs, userConfig, ... }:

let inherit (userConfig) colors;
in {
  home = {
    packages = with pkgs; [
      waybar
      eww
      mako
      wl-clipboard
      swww
      kanshi
      tofi
      wdisplays
      wlsunset
      grim
      slurp
    ];

    file = {
      hypr = {
        sources = ./hypr;
        target = "${config.home.homeDirectory}/.config/hypr";
      };
      tofi = {
        sources = ./tofi;
        target = "${config.home.homeDirectory}/.config/tofi";
      };
      waybar = {
        sources = ./waybar;
        target = "${config.home.homeDirectory}/.config/waybar";
      };
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
    };
  };

  services = {
    kanshi.enable = true;
    mako = {
      enable = true;
      borderRadius = 5;
      backgroundColor = "#${colors.background}";
      textColor = "#${colors.foreground}";
      borderColor = "#${colors.accent}";
      defaultTimeout = 20;
    };
    wlsunset = {
      enable = true;
      latitude = "54.2";
      longitude = "10.5";
    };
  };
}
