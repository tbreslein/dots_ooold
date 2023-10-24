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
      pkgs.ripgrep
      pkgs.tealdeer
    ];

    file = {
      nvim = mk_config config "nvim";
      up = {
        executable = true;
        target = "${config.home.homeDirectory}/.local/bin/up";
        text = ''
          #!/usr/bin/env bash
          pushd ${config.home.homeDirectory}/dots
          function up-hm {
              home-manager switch --flake .
          }
          function up-pkgs {
                if [[ $(uname) == "Darwin" ]]; then
                    npm update -g
                    HOMEBREW_NO_INSTALL_CLEANUP=1 brew update && HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade
                    brew cleanup
                    HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew update && HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew upgrade
                    axbrew cleanup
                    poetry self update
                else
                    sudo apt update && sudo apt upgrade
                fi
          }
          function up-nvim {
              nvim --headless "+Lazy! sync" +qa
          }
          case "$1" in
            hm) up-hm;;
            pkgs) up-pkgs;;
            nvim) up-nvim;;
            *) up-pkgs && up-hm && up-nvim;;
          esac
          popd
        '';
      };
    };

    shellAliases = {
      lg = "lazygit";
      cp = "cp -i";
      rm = "rm -i";
      mv = "mv -i";
      vim = "nvim";
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

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        character = {
          success_symbol = "[λ](bold yellow)";
          error_symbol = "[λ](bold red)";
          vicmd_symbol = "[λ](bold gree)";
        };
        directory = {
          truncate_to_repo = true;
          truncation_symbol = ".../";
          style = "bold blue";
        };
      };
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      plugins = with pkgs;
        with tmuxPlugins; [
          sensible
          vim-tmux-navigator
          yank
        ];
      extraConfig = ''
        if-shell "uname | grep -q Darwin" {
            set -g default-terminal "xterm-256color"
            set -ag terminal-overrides ",xterm-256color:RGB"
        } {
            set -g default-terminal "alacritty"
            set -ag terminal-overrides ",alacritty:RGB"
        }

        set-option -g renumber-windows on
        setw -g main-pane-height 60

        bind-key -n M-n previous-window
        bind-key -n M-m next-window

        bind-key C-g copy-mode
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel

        bind C-x split-window -v -c "#{pane_current_path}"
        bind C-v split-window -h -c "#{pane_current_path}"
        bind C-t new-window
        bind -r M-h resize-pane -L 5
        bind -r M-j resize-pane -D 5
        bind -r M-k resize-pane -U 5
        bind -r M-l resize-pane -R 5

        set -gq status-utf8 on
        set -g status-interval 30
        set -g status-justify left
        set -g status-left ""
        set -g status-right 'Session: #[fg=green] #S #[fg=white] | %H:%M '
        set -g status-style fg=white,bg=black
        set -g message-style fg=yellow,bold,bg=black
        setw -g window-status-style fg=white,bg=black
        setw -g window-status-current-style fg=yellow,bold,bg=black
        set -g pane-border-style fg=white,bg=black
        set -g pane-active-border-style fg=yellow,bg=black
      '';
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
