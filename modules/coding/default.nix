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
        scc
      ];
    };
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultShellAliases = mkOption {
      type = with types; attrsOf str;
      default = { lg = "lazygit"; };
    };
    extraShellAliases = mkOption {
      type = with types; attrsOf str;
      default = { };
    };
    nvimConfigSource = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/dots/nvim";
    };
    nvimConfigTarget = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/nvim";
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
      file = mkMerge [
        {
          nvim = {
            source = config.lib.file.mkOutOfStoreSymlink cfg.nvimConfigSource;
            target = cfg.nvimConfigTarget;
          };
        }
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

    programs.tmux = mkIf cfg.enableTmux {
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
  };
}
