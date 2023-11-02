{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      # compilers
      gcc

      # formatters / linters / language servers
      shellcheck
      shfmt
      yamllint
      prettierd
      statix
      nix
      nixfmt

      # cli tools
      go-task
      htop
      jq
      lazygit
      ripgrep
      rsync
      scc
      sd
      tealdeer
    ];
    file.smug = {
      source = ./smug;
      target = "${config.home.homeDirectory}/.config/smug";
    };

    shellAliases = {
      lg = "lazygit";
      rm = "rm -i";
      mv = "mv -i";
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

  programs = {
    bat = {
      enable = true;
      config.theme = "base16";
    };

    eza = {
      enable = true;
      enableAliases = true;
    };

    git = {
      enable = true;
      userName = "Tommy Breslein";
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
        options = {
          line-numbers = true;
          true-color = "always";
          features = "base16";
        };
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [ "--height 40%" ];
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        character = {
          success_symbol = "[λ](bold yellow)";
          error_symbol = "[λ](bold red)";
          vicmd_symbol = "[λ](bold green)";
        };
        directory = {
          truncate_to_repo = true;
          truncation_symbol = ".../";
          style = "bold blue";
        };
        format =
          "$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$line_break$nix_shell$battery$character";
        nix_shell.format = "[$symbol]($style)";
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
        set -g status-position top
        set -g status-justify left
        set -g status-left "#[fg=blue,bold] #S λ  "
        set -g status-right ""
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
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      initExtra = ''
        export KEYTIMEOUT=1
        export DISABLE_AUTO_TITLE=true
        bindkey -v

        setopt extendedglob nomatch menucomplete
        unsetopt BEEP
        stty stop undef # disable ctrl-s freezing the terminal
        zle_highlight=('paste:none') # stop highlighting pasted text
      '';
      history = {
        ignoreAllDups = true;
        ignoreSpace = true;
        save = 1000;
        size = 1000;
      };
    };
  };
}
