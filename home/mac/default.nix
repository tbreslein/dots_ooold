{ lib, userConfig, ... }:

{
  home.homeDirectory = lib.mkForce "/Users/${userConfig.name}";
  programs = {
    alacritty.settings.font.size = 18;
    zsh.shellAliases.twork =
      "smug dots --detach; smug notes --detach; smug planning";
  };
}
