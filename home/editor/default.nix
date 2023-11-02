{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [ neovim lua-language-server stylua ];
    file.nvim = {
      source = ./nvim;
      target = "${config.home.homeDirectory}/.config/nvim";
    };
    shellAliases = { vim = "nvim"; };
  };
}
