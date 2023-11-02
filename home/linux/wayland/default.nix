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

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    extraConfig = ''
      exec-once = waybar
      exec-once = mako
      exec-once = swww init & swww img ${config.home.homeDirectory}/dots/wallpapers/moebius.jpg
      exec = kanshi
      exec = wlsunset
    '';
    settings = {
      exec-once = [
        "waybar"
        "mako"
        "swww init & swww img ${config.home.homeDirectory}/dots/wallpapers/moebius.jpg"
      ];
      exec = [ "kanshi" "wlsunset" ];
      input.kb_layout = "us,de";
      general = {
        border_size = 2;
        "col.active_border" = "rgba(${colors.accent}ee)";
        "col.inactive_border" = "rgba(${colors.black}ee)";
        layout = "master";
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };
      decoration.rounding = 5;
      master = {
        mfact = 0.66;
        orientation = "right";
      };
      windowrulev2 = [
        "float,title:^(Picture(.)in(.)picture)$"
        "pin,title:^(Picture(.)in(.)picture)$"
        "float,class:^(steam)$,title:^(Friends list)$"
        "float,class:^(steam)$,title:^(Steam Settings)$"
        "workspace 3,class:^(steam)$"
        "workspace 3,class:^(lutris)$"
        "workspace 3,title:^(Wine System Tray)$"
        "workspace 4,class:^(battle.net.exe)$"
      ];
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, alacritty"
        "$mod, Space, exec, tofi-run | xargs hyprctl dispatch exec --"
        "$mod ALT, b, exec, brave"
        "$mod CTRL, q, killactive,"
        "$mod CTRL, m, exit,"
        "$mod SHIFT, f, fullscreen, 1"
        "$mod CTRL, f, fullscreen, 0"
        "$mod SHIFT, v, togglefloating,"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        "$mod CTRL, p, exec, grim -g '$(slurp)' ~/Pictures/$(date +'%s_grim.png')"
        "$mod ALT, p, exec, grim -g '$(slurp)' - | wl-copy"
        "$mod CTRL, o, exec, grim ~/Pictures/$(date +'%s_grim.png')"
        "$mod ALT, o, exec, grim - | wl-copy"

        "$mod SHIFT, j, cyclenext,"
        "$mod SHIFT, k, cyclenext, prev"
        "$mod CTRL, h, swapwindow, l"
        "$mod CTRL, j, swapwindow, d"
        "$mod CTRL, k, swapwindow, u"
        "$mod CTRL, l, swapwindow, r"
        "$mod, Tab, cyclenext,"
        "$mod, Tab, bringactivetotop,"

        "$mod ALT, h, resizeactive, -10,0"
        "$mod ALT, j, resizeactive, 0,10"
        "$mod ALT, k, resizeactive, ,-10"
        "$mod ALT, l, resizeactive, 10,0"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
      ];
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
    };
  };
}
