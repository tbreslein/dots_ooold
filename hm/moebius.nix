{ config, pkgs, user_name, mk_config, ... }: {
  imports = [ ./home.nix ./linux.nix ];
  home = { packages = [ pkgs.steam ]; };
  services = {
    kanshi = {
      profiles = {
        def = {
          outputs = [{
            criteria = "DP-3";
            mode = "3440x1440@144.000";
            adaptiveSync = true;
          }];
          exec = "swww init";
        };
      };
    };
  };
}
