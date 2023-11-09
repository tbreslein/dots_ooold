{ config, lib, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.colors;
in {
  options.conf.colors = {
    enable = lib.mkEnableOption "enable desktop apps";
    theme = mkOption {
      type = with types; enum string [ "gruvbox-material" ];
      default = "gruvbox-material";
    };
  };

  config = mkIf cfg.enable {
    home.colors = mkMerge [
      (mkIf (cfg.theme == "gruvbox-material") rec {
        background = "1d2021";
        foreground = white;
        bright_foreground = brightWhite;
        black = "32302f";
        red = "ea6962";
        green = "a9b665";
        yellow = "d8a657";
        blue = "7daea3";
        magenta = "d3869b";
        cyan = "89b482";
        white = "d4be98";

        brightBlack = black;
        brightRed = red;
        brightGreen = green;
        brightYellow = yellow;
        brightBlue = blue;
        brightMagenta = magenta;
        brightCyan = cyan;
        brightWhite = white;

        dimBlack = black;
        dimRed = red;
        dimGreen = green;
        dimYellow = yellow;
        dimBlue = blue;
        dimMagenta = magenta;
        dimCyan = cyan;
        dimWhite = white;

        accent = yellow;
        border = yellow;
      })
    ];
  };
}
