{ config, lib, colors, ... }:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.conf.desktop;
in {
  options.conf.desktop = {
    enable = lib.mkEnableOption "enable desktop apps";
    packages = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    terminalFontSize = mkOption {
      type = types.int;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home = {
      inherit (cfg) packages;
      sessionVariables.BROWSER = "brave";
    };
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          dynamic_padding = true;
          opacity = 0.92;
          option_as_alt = "OnlyLeft";
        };
        font = {
          normal.family = "Hack Nerd Font";
          size = cfg.terminalFontSize;
        };
        use_thin_strokes = true;
        cursor.style = {
          shape = "Block";
          blinking = "Never";
        };
        mouse.hide_when_typing = true;

        colors = {
          draw_bold_text_with_bright_colors = true;
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
}
