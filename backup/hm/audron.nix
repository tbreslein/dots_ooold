{ config, pkgs, user_name, ... }: { home = { packages = [ pkgs.neofetch ]; }; }
