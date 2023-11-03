{ config, pkgs, userConfig, ... }:
let inherit (userConfig) colors;
in {
  nixpkgs.config.allowUnfree = true;
  home = {
    username = userConfig.name;
    stateVersion = "23.05";
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "brave";
    };
    packages = [
      (pkgs.writeShellScriptBin "up-nvim" ''
        echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
        nvim --headless -u NONE -c "lua require('bootstrap').headless_paq()"
      '')

      (pkgs.writeShellScriptBin "up-nix" ''
        echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
        pushd ${config.home.homeDirectory}/dots
        if [[ -n $(git status -s) ]]; then
            echo "Error: git tree is dirty"
        else
            nix flake update
            if [[ -n $(git status -s) ]]; then
                git add flake.lock && git commit -m "update flake.lock"
            fi
            case "$(uname -s)" in
                Linux*) sudo nixos-rebuild switch --flake .;;
                Darwin*) darwin-rebuild switch --flake .;;
                *) echo "Error: unknown uname";;
            esac
        fi
        popd
      '')

      (pkgs.writeShellScriptBin "up" ''
        up-nix
        up-nvim
        case "$(uname -s)" in
            Linux*) up-protonge;;
            Darwin*) up-brew;;
            *) echo "Error: unknown uname";;
        esac
      '')
    ];
  };

  programs = {
    home-manager.enable = true;

    alacritty = {
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

        # onedark
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
  };

  services.syncthing.enable = true;
}
