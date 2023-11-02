{ config, pkgs, userConfig, ... }:

let gtkGruvboxPlus = import ./gtk-themes/gruvbox-plus.nix { inherit pkgs; };
in {
  home = {
    homeDirectory = "/home/${userConfig.name}";
    packages = with pkgs; [
      brave
      microsoft-edge
      discord
      telegram-desktop
      zathura

      imv
      mpv
      libnotify
      vlc
      playerctl
      pavucontrol
      nwg-look

      (writeShellScriptBin "up" ''
        pushd ${config.home.homeDirectory}/dots

        function up-nix {
            echo -e "\n\033[1;32m[ up-nix ]\033[0m"
            nix flake update
            if [[ -n $(git status -s) ]]; then
                git add flake.lock && git commit -m "update flake.lock"
            fi
            sudo nixos-rebuild switch --flake .
        }

        function up-nvim {
            echo -e "\n\033[1;32m[ up-nvim ]\033[0m"
            nvim --headless "+Lazy! sync" +qa
        }

        function up-protonge {
            echo -e "\n\033[1;32m[ up-protonge ]\033[0m"
            mkdir -p ~/tmp/proton-ge-custom
            cd ~/tmp/proton-ge-custom
            curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)"
            curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)"
            if [[ $(sha512sum -c ./*.sha512sum) ]]; then
                mkdir -p ~/.steam/root/compatibilitytools.d
                tar -xf GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
                echo "All done :)"
            else
                echo "Error: protonge sha512sum did not match!"
            fi
            rm -fr ~/tmp/proton-ge-custom
        }

        function up-all {
            up-nix
            up-nvim
            up-protonge
        }

        if [[ -n $(git status -s) ]]; then
            echo "Error: git tree is dirty"
        else
            case "$1" in
              nix) up-nix;;
              nvim) up-nvim;;
              pge) up-protonge;;
              all) up-all;;
              *) echo "Error: unknown command";;
            esac
        fi
        popd
      '')
    ];
  };

  # gtk = {
  #   enable = true;
  #   cursorTheme = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Classic-Ice";
  #   };
  #   theme = {
  #     package = pkgs.adw-gtk3;
  #     name = "adw-gtk3";
  #   };
  #   iconTheme = {
  #     package = gtkGruvboxPlus;
  #     name = "GruvboxPlus";
  #   };
  # };

  services.syncthing.enable = true;
}
