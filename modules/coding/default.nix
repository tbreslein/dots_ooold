{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.conf.coding;

  plainDev = {
    name = "dev";
    panes = [ "-" ];
  };
  plainSh = {
    name = "sh";
    panes = [ "-" ];
  };
  npmRunServe = {
    name = "server";
    panes = [ "- commands: [npm run serve]" ];
  };
  defaultWindows = [ plainDev plainSh ];

  mkWindow = { name, panes, root ? "." }:
    "\n  - name: ${name}\n    root: ${root}\n    panes:\n"
    + lib.concatStringsSep "\n" (map (x: "      " + x) panes);

  mkSmug = name: root: windows: {
    target = "${config.home.homeDirectory}/.config/smug/${name}.yml";
    text = ''
      ---
      session: ${name}
      root: ~/${root}
      windows: ${lib.concatStringsSep "\n" (map mkWindow windows)}
    '';
  };
in {
  options.conf.coding = {
    enable = mkEnableOption "enable coding tools";
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        gcc
        cmake
        gnumake

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

        go-task
        lazygit
        pandoc
      ];
    };
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultShellAliases = mkOption {
      type = with types; attrsOf str;
      default = {
        lg = "lazygit";
        vim = "nvim";
      };
    };
    extraShellAliases = mkOption {
      type = with types; attrsOf str;
      default = { };
    };
    enableTmux = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = mkMerge [
        cfg.defaultPkgs
        cfg.extraPkgs
        (mkIf cfg.enableTmux [ pkgs.smug ])
      ];
      sessionVariables.EDITOR = lib.mkForce "nvim";
      file = mkMerge [
        (mkIf cfg.enableTmux {
          smug_notes = mkSmug "notes" "syncthing/notes" [ plainDev ];
          smug_dots = mkSmug "dots" "dots" [ plainDev ];
          smug_corries = mkSmug "corries" "coding/corries" defaultWindows;
          smug_tdos = mkSmug "tdos" "coding/tdos" defaultWindows;
          smug_frankenrepo =
            mkSmug "frankenrepo" "coding/frankenrepo" defaultWindows;
          smug_frankenrepo-dev =
            mkSmug "frankenrepo.dev" "coding/frankenrepo.dev"
            (defaultWindows ++ [ npmRunServe ]);
          smug_capturedlambda = mkSmug "capturedlambda" "coding/capturedlambda"
            (defaultWindows ++ [ npmRunServe ]);
          smug_planning = mkSmug "planning" "work/planning" (defaultWindows
            ++ [{
              name = "moco";
              root = "../MocoTrackingClient";
              panes = [ "- commands: [poetry run python moco_client.py]" ];
            }]);
        })
        ({
          "${config.home.homeDirectory}/.config/nvim".source =
            config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dots/modules/coding/nvim";
        })
      ];

      shellAliases = mkMerge [ cfg.defaultShellAliases cfg.extraShellAliases ];
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
      neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
      };
      tmux = mkIf cfg.enableTmux {
        enable = true;
        prefix = "C-a";
        baseIndex = 1;
        clock24 = true;
        escapeTime = 0;
        historyLimit = 10000;
        keyMode = "vi";
        mouse = true;
        plugins = with pkgs; with tmuxPlugins; [ sensible yank ];
        extraConfig = ''
          set -g default-terminal "alacritty"
          set -ag terminal-overrides ",alacritty:RGB"

          set-option -g renumber-windows on
          setw -g main-pane-height 60

          bind-key -n M-n previous-window
          bind-key -n M-e next-window

          bind-key C-g copy-mode
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
          bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel

          bind C-x split-window -v -c "#{pane_current_path}"
          bind C-v split-window -h -c "#{pane_current_path}"
          bind C-t new-window

          is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?\.?(view|n?vim?x?)(-wrapped)?(diff)?$'"

          bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
          bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
          bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
          bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

          bind-key -T copy-mode-vi 'C-h' select-pane -L
          bind-key -T copy-mode-vi 'C-j' select-pane -D
          bind-key -T copy-mode-vi 'C-k' select-pane -U
          bind-key -T copy-mode-vi 'C-l' select-pane -R

          bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 1'
          bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 1'
          bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 1'
          bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 1'

          bind-key -T copy-mode-vi M-h resize-pane -L 1
          bind-key -T copy-mode-vi M-j resize-pane -D 1
          bind-key -T copy-mode-vi M-k resize-pane -U 1
          bind-key -T copy-mode-vi M-l resize-pane -R 1

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
    };
  };
}
