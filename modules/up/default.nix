{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.up;
in {
  options.conf.up = {
    system = mkOption {
      type = with types; enum [ "darwin" "nixos" ];
      default = null;
    };
    addProtonGE = lib.mkEnableOption "add up-protonge";
  };

  config = {
    home.packages = mkMerge [
      [
        (mkIf cfg.addProtonGE (pkgs.writeShellScriptBin "up-protonge" ''
          echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
          mkdir -p ~/tmp/proton-ge-custom
          pushd ~/tmp/proton-ge-custom
          curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)"
          curl -LOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)"
          if [[ $(sha512sum -c ./*.sha512sum) ]]; then
              mkdir -p ~/.steam/root/compatibilitytools.d
              tar -xf GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
              echo "All done :)"
          else
              echo "Error: protonge sha512sum did not match!"
          fi
          popd
          rm -fr ~/tmp/proton-ge-custom
        ''))
      ]

      [
        (pkgs.writeShellScriptBin "up-nix" ''
          echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
          pushd ${config.home.homeDirectory}/dots
          if [[ -n $(git status -s) ]]; then
              echo "Error: git tree is dirty"
          else
              git pull
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
      ]

      [
        (pkgs.writeShellScriptBin "up-nvim" ''
          echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
          nvim --headless "+Lazy! sync" "+TSUpdate" +qa
        '')
      ]

      [
        (pkgs.writeShellScriptBin "up" ''
          up-nix
          command -v up-protonge &>/dev/null && up-protonge || true
          command -v nvim &>/dev/null && up-nvim || true
        '')
      ]
    ];
  };
}
