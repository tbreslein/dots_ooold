{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [ neovim stylua ];
    file.nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dots/home/editor/nvim";
      target = "${config.home.homeDirectory}/.config/nvim";
    };
    shellAliases = { vim = "nvim"; };
  };
}
