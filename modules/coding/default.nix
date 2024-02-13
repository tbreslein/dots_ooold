{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.conf.coding;

  # plainDev = {
  #   name = "dev";
  #   panes = [ "-" ];
  # };
  # plainSh = {
  #   name = "sh";
  #   panes = [ "-" ];
  # };
  # npmRunServe = {
  #   name = "server";
  #   panes = [ "- commands: [npm run serve]" ];
  # };
  # defaultWindows = [ plainDev plainSh ];
  #
  # mkWindow = { name, panes, root ? "." }:
  #   "\n  - name: ${name}\n    root: ${root}\n    panes:\n"
  #   + lib.concatStringsSep "\n" (map (x: "      " + x) panes);
  #
  # mkSmug = name: root: windows: {
  #   target = "${config.home.homeDirectory}/.config/smug/${name}.yml";
  #   text = ''
  #     ---
  #     session: ${name}
  #     root: ~/${root}
  #     windows: ${lib.concatStringsSep "\n" (map mkWindow windows)}
  #   '';
  # };

  plainDev = {
    window_name = "dev";
    panes = [{ shell_command = [ "" ]; }];
  };

  plainSh = {
    window_name = "sh";
    panes = [{ shell_command = [ "" ]; }];
  };

  npmRunServe = {
    window_name = "server";
    panes = [{ shell_command = [ "npm run serve" ]; }];
  };

  defaultWindows = [ plainDev plainSh ];

  mkTmuxpSession = { session_name, start_directory, windows ? defaultWindows
    , extraConfig ? { } }: {
      target =
        "${config.home.homeDirectory}/.config/tmuxp/${session_name}.json";
      text = builtins.toJSON
        ({ inherit session_name start_directory windows; } // extraConfig);
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
        (mkIf cfg.enableTmux [ pkgs.tmuxp ])
      ];
      sessionVariables.EDITOR = lib.mkForce "nvim";
      file = mkMerge [
        (mkIf cfg.enableTmux {
          # mkTmuxpSession = { session_name, start_directory, windows ? defaultWindows
          #   , extraConfig ? { } }: {
          tmuxp_notes = mkTmuxpSession {
            session_name = "notes";
            start_directory = "${config.home.homeDirectory}/syncthing/notes";
            windows = [ plainDev ];
          };
          tmuxp_dots = mkTmuxpSession {
            session_name = "dots";
            start_directory = "${config.home.homeDirectory}/dots";
          };
          tmuxp_corries = mkTmuxpSession {
            session_name = "corries";
            start_directory = "${config.home.homeDirectory}/coding/corries";
          };
          tmuxp_frankenrepo = mkTmuxpSession {
            session_name = "frankenrepo";
            start_directory = "${config.home.homeDirectory}/coding/frankenrepo";
          };
          tmuxp_capturedlambda = mkTmuxpSession {
            session_name = "capturedlambda";
            start_directory =
              "${config.home.homeDirectory}/coding/capturedlambda";
            windows = defaultWindows ++ [ npmRunServe ];
          };
          tmuxp_planning = mkTmuxpSession {
            session_name = "planning";
            start_directory = "${config.home.homeDirectory}/work/planning";
          };
          tmuxp_planning_docs = mkTmuxpSession {
            session_name = "planning_docs";
            start_directory = "${config.home.homeDirectory}/work/documentation";
          };
          tmuxp_schlogg = mkTmuxpSession {
            session_name = "planning_schlogg";
            start_directory = "${config.home.homeDirectory}/work/schlogg";
          };
          tmuxp_curls = mkTmuxpSession {
            session_name = "planning_curls";
            start_directory =
              "${config.home.homeDirectory}/work/api-test-curls";
          };
          tmuxp_moco = mkTmuxpSession {
            session_name = "planning_moco";
            start_directory =
              "${config.home.homeDirectory}/work/MocoTrackingClient";
            windows = [{
              window_name = "serve";
              panes =
                [{ shell_command = [ "poetry run python moco_client.py" ]; }];
            }];
          };
        })
        {
          "${config.home.homeDirectory}/.config/nvim".source =
            config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dots/modules/coding/nvim";
        }
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

          bind-key -n M-j previous-window
          bind-key -n M-k next-window

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
