{ config, lib, ... }:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.conf.systemDefaults;
in {
  options.conf.systemDefaults = { };

  config = mkMerge [
    (mkIf (cfg.system == "wsl") {
      imports = [ <nixos-wsl/modules> ];
      wsl = {
        enable = true;
        defaultUser = "tommy";
      };
    })
  ];
}
