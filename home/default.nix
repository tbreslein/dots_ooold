{ config, pkgs, userConfig, ... }:

{
  nixpkgs.config.allowUnfree = true;
  home = {
    username = userConfig.name;
    stateVersion = "23.05";
    sessionVariables.EDITOR = "nvim";
    packages = [
      (pkgs.writeShellScriptBin "up-nvim" ''
        echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
        nvim --headless -u NONE -c "lua require('bootstrap').headless_paq()"
      '')

      (pkgs.writeShellScriptBin "up-nix" ''
        echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
        pushd ${config.home.homeDirectory}/dots
        if [[ -n $(git status -s) ]]; then
            echo "Error: git tree is dirty"
        else
            nix flake update
            if [[ -n $(git status -s) ]]; then
                git add flake.lock && git commit -m "update flake.lock"
            fi
            case "$(uname -s)" in
                Linux*) sudo nixos-rebuild switch --impure --flake .;;
                Darwin*) darwin-rebuild switch --flake .;;
                *) echo "Error: unknown uname";;
            esac
        fi
        popd
      '')

      (pkgs.writeShellScriptBin "up" ''
        up-nix
        up-nvim
        case "$(cat /etc/hostname)" in
            moebius) up-protonge;;
            *);;
        esac
      '')
    ];
  };

  programs.home-manager.enable = true;
  services.syncthing.enable = true;
}
