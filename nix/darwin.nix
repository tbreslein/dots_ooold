{ config, pkgs, user_name, ... }: {
  home = {
    homeDirectory = "/Users/${user_name}";
    #packages = [
    #];
  };
}
