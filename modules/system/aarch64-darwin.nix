{ config, lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkOption types;
  cfg = config.conf.systemDefaults;
in {
  options.conf.systemDefaults = {
    extraCasks = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultCasks = mkOption {
      type = with types; listOf str;
      default = [ "amethyst" "alacritty" ];
    };
  };

  config = {
    nix = {
      useDaemon = true;
      gc.interval.Hour = 168;
      settings.auto-optimise-store = true;
      extraOptions = "experimental-features = nix-command flakes";
    };

    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
      defaults = {
        CustomUserPreferences = {
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowHardDrivesOnDesktop = true;
            ShowMountedServersOnDesktop = true;
            ShowRemovableMediaOnDesktop = true;
            _FXSortFoldersFirst = true;
            # When performing a search, search the current folder by default
            FXDefaultSearchScope = "SCcf";
          };
        };
        finder = {
          AppleShowAllExtensions = true;
          _FXShowPosixPathInTitle = true;
        };
        dock = {
          autohide = true;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.2;
          expose-animation-duration = 0.2;
          launchanim = false;
          orientation = "bottom";
          showhidden = true;
          show-process-indicators = true;
          show-recents = false;
          static-only = true;
          tilesize = 48;
        };
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleShowAllExtensions = true;
          InitialKeyRepeat = 10;
        };
      };
    };

    fonts = {
      fontDir.enable = true;
      fonts = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
    };

    programs = {
      bash.enable = true;
      fish.enable = true;
      zsh.enable = true;
    };

    environment = {
      # loginShell = pkgs.zsh;
      systemPackages = with pkgs; [ poetry python3 ];
      shells = with pkgs; [ bashInteractive fish ];
      loginShell = pkgs.bashInteractive;
    };
    homebrew = {
      onActivation = {
        autoUpdate = true;
        upgrade = true;
      };
      enable = true;
      caskArgs.no_quarantine = true;
      global.brewfile = true;
      # macApps = {};
      casks = mkMerge [ cfg.extraCasks cfg.defaultCasks ];
    };
    # launchd.agents.mococlient =
    #   let mocodir = "/Users/tommy/work/MocoTrackingClient";
    #   in {
    #     # path = with pkgs; [ poetry python3 ];
    #     environment.POETRY_VIRTUALENVS_IN_PROJECT = "true";
    #     serviceConfig = {
    #       Label = "mococlient";
    #       KeepAlive = true;
    #       RunAtLoad = true;
    #       UserName = "tommy";
    #       StandardOutPath = "/Users/tommy/.mococlient.out.log";
    #       StandardErrorPath = "/Users/tommy/.mococlient.err.log";
    #       WorkingDirectory = mocodir;
    #       ProcessType = "Interactive";
    #       ProgramArguments = [
    #         "${pkgs.poetry}/bin/poetry"
    #         "run"
    #         "${pkgs.python3}/bin/python3"
    #         "moco_client.py"
    #       ];
    #     };
    #   };
  };
}
