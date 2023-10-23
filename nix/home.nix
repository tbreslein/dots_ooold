{ config, pkgs, user_name, mk_config, ... }: {
  nixpkgs.config.allowUnfree = true;
  news.display = "show";
  home = {
    username = user_name;
    stateVersion = "23.05";
    packages = [
      # coding
      pkgs.gcc
      pkgs.neovim
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.yamllint
      pkgs.prettierd
      pkgs.statix
      pkgs.nil
      pkgs.nixfmt

      # cli
      pkgs.bat
      pkgs.bottom
      pkgs.jq
      pkgs.lazygit
      pkgs.tmux
    ];

    file = {
      nvim = mk_config config "nvim";
      tmux = mk_config config "tmux";
    };

    shellAliases = {
      lg = "lazygit";
      cp = "cp -i";
      rm = "rm -i";
      mv = "mv -i";
    };

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "brave";
    };
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        trim_trailing_whitespace = true;
        max_line_width = 80;
        indent_style = "space";
        indent_size = 4;
      };
      "*.{nix,cabal,hs,json,js,jsx,ts,tsx,cjs,mjs,yml,yaml,ml,mli,hl,md,mdx,html},CMakeLists.txt" =
        {
          indent_size = 2;
        };
      "Makefile" = { indent_style = "tab"; };
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    eza = {
      enable = true;
      enableAliases = true;
    };
    git = {
      enable = true;
      aliases = {
        a = "add";
        aa = "add .";
        cm = "commit -m";
        cam = "commit -am";
        p = "push";
        pf = "push --force-with-lease";
        pu = "push -u";
        pl = "pull";
        co = "checkout";
        cb = "checkout --branch";
        br = "branch";
        sw = "switch";
        st = "status";
      };
      delta = {
        enable = true;
        options = { line-numbers = true; };
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      defaultOptions = [ "--height 40%" ];
    };
  };
}
