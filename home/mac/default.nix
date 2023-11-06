{ config, pkgs, lib, userConfig, ... }:

{
  home = {
    homeDirectory = lib.mkForce "/Users/${userConfig.name}";
    packages = [
      (pkgs.writeShellScriptBin "up-brew" ''
        echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
        #export HOMEBREW_NO_INSTALL_CLEANUP=1
        #brew update && brew upgrade && brew cleanup
        #axbrew update && axbrew upgrade && axbrew cleanup
        #poetry self update
      '')
    ];
  };
  programs = {
    alacritty.settings.font.size = 18;
    zsh.shellAliases.twork =
      "smug dots --detach; smug notes --detach; smug planning";
  };
}
