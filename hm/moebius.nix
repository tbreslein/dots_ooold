{ config, pkgs, userConfig, ... }: {
  imports = [ ./home.nix ./linux.nix ];
  services = {
    kanshi = {
      profiles = {
        def = {
          outputs = [{
            criteria = "DP-3";
            mode = "3440x1440@144.000";
          }];
        };
      };
    };
  };
}
