{ config, pkgs, ... }:

{
  imports = [ ./smug ];
  home = {
    packages = with pkgs; [
      neovim

      # compilers
      gcc
      cmake
      gnumake

      # formatters / linters / language servers
      shellcheck
      shfmt
      yamllint
      prettierd
      eslint_d
      statix
      nil
      nixfmt
      marksman
      prettierd
      stylua

      # cli tools
      go-task
      lazygit
      pandoc
      scc
      smug
    ];

    sessionVariables = {
      CC = "gcc";
      CXX = "g++";
    };
    file.nvim = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dots/home/coding/nvim";
      target = "${config.home.homeDirectory}/.config/nvim";
    };
    shellAliases = {
      lg = "lazygit";
      vim = "nvim";
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

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs; with tmuxPlugins; [ sensible vim-tmux-navigator yank ];
    extraConfig = ''
      #if-shell "uname | grep -q Darwin" {
      #    set -g default-terminal "xterm-256color"
      #    set -ag terminal-overrides ",xterm-256color:RGB"
      #} {
      #    set -g default-terminal "alacritty"
      #    set -ag terminal-overrides ",alacritty:RGB"
      #}
      set -g default-terminal "alacritty"
      set -ag terminal-overrides ",alacritty:RGB"

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
}
