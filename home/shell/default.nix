{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      # cli tools
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

    shellAliases = {
      rm = "rm -i";
      mv = "mv -i";
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
        username.format = "[$user]($style)@";
        hostname.format = "[$ssh_symbol$hostname]($style)";
        format =
          "$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$line_break$username$hostname: $nix_shell$battery$character";
        nix_shell.format = "[$symbol]($style)";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

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
}
