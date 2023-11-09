{ config, lib, pkgs, builtins, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.up;
in {
  options.conf.up = {
    system = mkOption {
      type = with types; enum [ "darwin" "nixos" ];
      default = null;
    };
    additionalRoles = mkOption {
      type = with types; listOf (enum [ "coding" "gaming" ]);
      default = [ ];
    };
  };

  config = {
    home.packages = mkMerge [
      (mkIf (builtins.elem "coding" cfg.additionalRoles)
        (pkgs.writeShellScriptBin "up-nvim" ''
          echo -e "\n\033[1;32m[ $(basename $0) ]\033[0m"
          CC=gcc CXX=g++ nvim --headless "+Lazy! sync" "+TSUpdateSync" +qa
        ''))

      (mkIf (builtins.elem "gaming" cfg.additionalRoles)
        (pkgs.writeShellScriptBin "up-protonge" ''
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
            ${mkIf (cfg.system == "darwin") "darwin-rebuild switch --flake ."}
            ${
              mkIf (cfg.system == "nixos")
              "sudo nixos-rebuild switch --impure --flake ."
            }
        fi
        popd
      '')

      (pkgs.writeShellScriptBin "up" ''
        up-nix
        ${mkIf (builtins.elem "gaming" cfg.additionalRoles) "up-nvim"}
        ${mkIf (builtins.elem "gaming" cfg.additionalRoles) "up-protonge"}
      '')
    ];
  };
}
