{ config, pkgs, user_name, ... }: {
  home = {
    homeDirectory = "/Users/${user_name}";
    #packages = [
    #];
    file = {
      up = {
        executable = true;
        target = "${config.home.homeDirectory}/.local/bin/up";
        text = ''
          #!/usr/bin/env zsh
          source ~/.zshrc
          pushd ${config.home.homeDirectory}/dots
          [[ -n $(git status -s) ]] && echo "git tree is dirty" && popd && return 1
          function up-hm {
              nix-collect-garbage -d
              nix flake update
              if [[ -n $(git status -s) ]]; then
                  git add flake.lock && git commit -m "update flake.lock"
              fi
              home-manager switch --flake .
          }
          function up-pkgs {
              npm update -g
              HOMEBREW_NO_INSTALL_CLEANUP=1 brew update && HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade
              brew cleanup
              HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew update && HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew upgrade
              axbrew cleanup
              poetry self update
          }
          function up-nvim {
              nvim --headless "+Lazy! sync" +qa
          }
          function up-all {
              up-pkgs && up-hm && up-nvim
          }
          case "$1" in
            hm) up-hm;;
            pkgs) up-pkgs;;
            nvim) up-nvim;;
            all) up-all;;
          esac
          popd
        '';
      };
    };
  };
  programs = {
    pyenv = {
      enable = true;
      enableZshIntegration = true;
    };

    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require("wezterm")
        local config = {}

        config.window_close_confirmation = 'NeverPrompt'
        config.enable_tab_bar = false
        config.window_background_opacity = 0.90
        config.color_scheme = "Gruvbox Material (Gogh)"
        config.colors = { background = "#1d2021" }
        config.force_reverse_video_cursor = true

        config.font = wezterm.font("CommitMono Nerd Font")
        local handle = assert(io.popen("uname", "r"))
        local uname = handle:read("*a")
        handle:close()
        if uname:find("Linux", 1, true) == 1 then
            config.font_size = 15
        else
            config.font_size = 19
        end

        config.disable_default_key_bindings = true
        config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
        config.keys = {
            { key = "p", mods = "LEADER", action = wezterm.action.ActivateCommandPalette },
            { key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
            { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
            { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
            { key = "c", mods = "SUPER", action = wezterm.action.CopyTo("Clipboard") },
            { key = "Copy", action = wezterm.action.CopyTo("Clipboard") },
            {
                key = "Insert",
                mods = "CTRL",
                action = wezterm.action.CopyTo("PrimarySelection"),
            },
            { key = "v", mods = "SUPER", action = wezterm.action.PasteFrom("Clipboard") },
            { key = "Paste", action = wezterm.action.PasteFrom("Clipboard") },
            {
                key = "Insert",
                mods = "SHIFT",
                action = wezterm.action.CopyTo("PrimarySelection"),
            },
        }

        return config
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "vicmd";
      initExtra = ''
        export KEYTIMEOUT=1
        export DISABLE_AUTO_TITLE=true
        bindkey -v '^?' backward-delete-char

        setopt extendedglob nomatch menucomplete
        unsetopt BEEP
        stty stop undef # disable ctrl-s freezing the terminal
        zle_highlight=('paste:none') # stop highlighting pasted text

        zstyle :compinstall filename "$ZDOTDIR/.zshrc"
        zstyle ':completion:*' menu select
        autoload -Uz compinit
        _comp_options+=(globdots)
        compinit
      '';
      history = {
        ignoreAllDups = true;
        ignoreSpace = true;
        save = 100000;
        size = 100000;
      };
    };
  };
}
