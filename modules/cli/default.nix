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
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
        historyIgnore = [ "ls" "cd" "exit" ];
        initExtra = ''
          PS1='\n`if [ \$? != 0 ]; then echo -n \[\e[31m$? \]; fi`\[\e[92m\e[1m\][\u@\h]: \[\e[0m\]\w `if [ \$(git rev-parse --is-inside-work-tree 2>/dev/null) ]; then if [[ -n \$(git status -s) ]]; then echo -n \[\e[31m \]; fi; if [[ -n \$(git cherry -v) ]]; then echo -n \[\e[31m󰶣 \]; fi; fi`\e[0m\n\[\e[1m\e[1m\e[93m\]λ\[\e[0m\] '
        '';
      };
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      eza = {
        enable = true;
        enableAliases = true;
      };
      fzf = {
        enable = true;
        enableBashIntegration = true;
      };
      git = {
        enable = true;
        extraConfig = { pull.rebase = true; };
        userName = "Tommy Breslein";
        userEmail = cfg.gitEmail;
        delta = {
          enable = true;
          options = {
            line-numbers = true;
            true-color = "always";
            features = "base16";
          };
        };
      };
      # starship = {
      #   enable = true;
      #   enableBashIntegration = true;
      #   settings = {
      #     character = {
      #       success_symbol = "[λ](bold yellow)";
      #       error_symbol = "[λ](bold red)";
      #       vicmd_symbol = "[λ](bold green)";
      #     };
      #     directory = {
      #       truncate_to_repo = true;
      #       truncation_symbol = ".../";
      #       style = "bold blue";
      #     };
      #     username.format = "[$user]($style)@";
      #     hostname.format = "[$ssh_symbol$hostname]($style): ";
      #     format =
      #       "$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$line_break$username$hostname$nix_shell$battery$character";
      #     nix_shell.format = "[$symbol]($style)";
      #   };
      # };
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
