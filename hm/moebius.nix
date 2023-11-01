{ ... }: {
  imports = [ ./home.nix ./linux.nix ];
  programs.alacritty.settings.font.size = 12;
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
