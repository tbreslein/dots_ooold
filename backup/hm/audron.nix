{ config, pkgs, user_name, mk_config, ... }: {
  imports = [ ./home.nix ./linux.nix ];
  home = { packages = [ pkgs.steam ]; };
}
