{ pkgs, userConfig, ... }:

let
  inherit (userConfig) colors;
  gtkGruvboxPlus = import ./gtk-themes/gruvbox-plus.nix { inherit pkgs; };
in {
  home = {
    sessionVariables.BROWSER = "brave";
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

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dynamic_padding = true;
        opacity = 0.92;
        option_as_alt = "OnlyLeft";
      };
      font.normal.family = "Hack Nerd Font";
      use_thin_strokes = true;
      draw_bold_text_with_bright_colors = true;
      cursor.style = {
        shape = "Block";
        blinking = "Never";
      };
      mouse.hide_when_typing = true;

      colors = {
        primary = {
          background = "0x${colors.background}";
          foreground = "0x${colors.foreground}";
        };
        normal = {
          black = "0x${colors.black}";
          red = "0x${colors.red}";
          green = "0x${colors.green}";
          yellow = "0x${colors.yellow}";
          blue = "0x${colors.blue}";
          magenta = "0x${colors.magenta}";
          cyan = "0x${colors.cyan}";
          white = "0x${colors.white}";
        };
        bright = {
          black = "0x${colors.brightBlack}";
          red = "0x${colors.brightRed}";
          green = "0x${colors.brightGreen}";
          yellow = "0x${colors.brightYellow}";
          blue = "0x${colors.brightBlue}";
          magenta = "0x${colors.brightMagenta}";
          cyan = "0x${colors.brightCyan}";
          white = "0x${colors.brightWhite}";
        };
        dim = {
          black = "0x${colors.dimBlack}";
          red = "0x${colors.dimRed}";
          green = "0x${colors.dimGreen}";
          yellow = "0x${colors.dimYellow}";
          blue = "0x${colors.dimBlue}";
          magenta = "0x${colors.dimMagenta}";
          cyan = "0x${colors.dimCyan}";
          white = "0x${colors.dimWhite}";
        };
      };
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
