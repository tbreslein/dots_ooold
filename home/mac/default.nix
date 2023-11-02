{ config, pkgs, lib, userConfig, ... }:

{
  home = {
    homeDirectory = lib.mkForce "/Users/${userConfig.name}";
    packages = [
      (pkgs.writeShellScriptBin "up" ''
        source ~/.zshrc
        pushd ${config.home.homeDirectory}/dots

        function up-nix {
            echo -e "\n\033[1;32m[ up-nix ]\033[0m"
            nix-collect-garbage -d
            nix flake update
            if [[ -n $(git status -s) ]]; then
                git add flake.lock && git commit -m "update flake.lock"
            fi
            darwin-rebuild switch --flake .
        }

        # function up-pkgs {
        #     echo -e "\n\033[1;32m[ up-pkgs ]\033[0m"
        #     HOMEBREW_NO_INSTALL_CLEANUP=1 brew update && HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade
        #     brew cleanup
        #     HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew update && HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew upgrade
        #     axbrew cleanup
        #     poetry self update
        # }

        function up-nvim {
            echo -e "\n\033[1;32m[ up-nvim ]\033[0m"
            #nvim --headless "+Lazy! sync" +qa
            nvim --headless -u NONE -c "lua require('bootstrap').headless_paq()"
        }

        function up-all {
            # up-pkgs && up-nix && up-nvim
            up-nix && up-nvim
        }

        case "$1" in
          nix)
            if [[ -n $(git status -s) ]]; then
                echo "Error: git tree is dirty"
            else
              up-nix
            fi
            ;;
          # pkgs) up-pkgs;;
          nvim) up-nvim;;
          all) up-all;;
          *) echo "Error: unknown command";;
        esac
        popd
      '')
    ];
  };
  programs = {
    alacritty.settings.font.size = 15;
    zsh.shellAliases.twork = "smug dots --detach; smug planning";
  };
}
