{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.cli;
in {
  options.conf.cli = {
    enable = lib.mkEnableOption "enable cli tools";
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        bat
        fd
        htop
        jq
        pfetch-rs
        ripgrep
        rm-improved
        rsync
        sd
        tealdeer
      ];
    };
    gitEmail = mkOption {
      type = types.str;
      default = "tommy.breslein@protonmail.com";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        # in fish and nushell, this is just enabled by default
        #enableFishIntegration = true;
        #enableNushellIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      eza = {
        enable = true;
        enableAliases = true;
      };
      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
      };
      git = {
        enable = true;
        extraConfig = {
          pull.rebase = true;
          push = {
            autoSetupRemote = true;
            default = "simple";
          };
        };
        userName = "Tommy Breslein";
        userEmail = cfg.gitEmail;
        delta = {
          enable = true;
          options = {
            line-numbers = true;
            true-color = "always";
          };
        };
      };
      starship = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = true;
        enableNushellIntegration = true;
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
            "$battery$directory$nix_shell$vcsh$fossil_branch$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$line_break$character";
          nix_shell.format = "[$symbol]($style)";
        };
      };
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
      };
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
        historyIgnore = [ "ls" "cd" "exit" ];
        initExtra = ''
          PS1='\n`if [ \$? != 0 ]; then echo -n \[\e[31m$? \]; fi`\[\e[92m\e[1m\][\u@\h]: \[\e[0m\]\w `if [ \$(git rev-parse --is-inside-work-tree 2>/dev/null) ]; then if [[ -n \$(git status -s) ]]; then echo -n \[\e[31m \]; fi; if [[ -n \$(git cherry -v) ]]; then echo -n \[\e[31m󰶣 \]; fi; fi`\e[0m\n\[\e[1m\e[1m\e[93m\]λ\[\e[0m\] '
        '';
      };
      fish = {
        enable = true;
        interactiveShellInit = "set -g fish_greeting";
      };
      nushell = { enable = true; };
      zsh = {
        enable = true;
        enableCompletion = false;
        enableAutosuggestions = false;
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
  };
}
