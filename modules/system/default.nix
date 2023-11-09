{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.conf.systemDefaults;
in {
  options.conf.systemDefaults = {
    system = mkOption {
      type = with types; enum [ "darwin" "linux" "wsl" ];
      # default = [ ];
    };
    extraPkgs = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    defaultPkgs = mkOption {
      type = with types; listOf package;
      default = with pkgs; [ vim coreutils wget curl unzip git killall ];
    };
    enableGaming = lib.mkEnableOption "enable gaming stuff";
  };

  config = mkMerge [
    {
      nixpkgs.config.allowUnfree = true;
      nix = {
        gc = {
          automatic = true;
          options = "--delete-older-than 1w";
        };
        settings = {
          trusted-users = [ "tommy" ];
          substituters = [ "https://cachix.cachix.org" ];
          trusted-public-keys = [
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          ];
        };
      };
      environment.systemPackages = mkMerge [ cfg.defaultPkgs cfg.extraPkgs ];
      programs.zsh.enable = true;
      time.timeZone = "Europe/Berlin";
    }

    (mkIf (cfg.system == "darwin") {
      nix = {
        useDaemon = true;
        # gc.interval.Weeks = 1;
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
        fonts = with pkgs; [
          (nerdfonts.override { fonts = [ "Hack" ]; })
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
        ];
      };

      environment.loginShell = pkgs.zsh;
      homebrew = {
        onActivation = {
          autoUpdate = true;
          upgrade = true;
        };
        enable = true;
        caskArgs.no_quarantine = true;
        global.brewfile = true;
        # macApps = {};
        casks = [ "amethyst" "alacritty" ];
      };
      # launchd = {
      #   ...
      # };
    })

    (mkIf (cfg.system == "linux" || cfg.system == "wsl") {
      nix = {
        optimise.automatic = true;
        gc.dates = "weekly";
        settings.experimental-features = [ "nix-command" "flakes" ];
      };

      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        extraHosts = ''
          192.168.0.92 audron
          192.168.0.91 moebius
          192.168.0.90 vorador
        '';
      };
      security = {
        rtkit.enable = true;
        polkit.enable = true;
      };
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      i18n.defaultLocale = "en_US.UTF-8";

      users.users.tommy = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        initialPassword = "qwert";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keyFiles = ./id_rsa.pub;
      };

      system.stateVersion = "23.05";
    })

    (mkIf (cfg.system == "linux") { })
    (mkIf (cfg.system == "wsl") {
      imports = [ <nixos-wsl/modules> ];
      wsl = {
        enable = true;
        defaultUser = "tommy";
      };
    })

    (mkIf cfg.enableGaming {
      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
        };
        corectrl.enable = true;
        gamemode.enable = true;
      };
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if ((action.id == "org.corectrl.helper.init" ||
                 action.id == "org.corectrl.helperkiller.init") &&
                subject.local == true &&
                subject.active == true &&
                subject.isInGroup("wheel")) {
                    return polkit.Result.YES;
            }
        });
      '';
    })
  ];
}
