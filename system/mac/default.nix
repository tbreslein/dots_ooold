{ pkgs, ... }:

{
  nix = {
    useDaemon = true;
    gc = {
      automatic = true;
      #interval.Weeks = 1;
      options = "--delete-older-than 1w";
    };
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
  # homebrew = {
  #   enable = true;
  #   caskArgs.no_quarantine = true;
  #   global.brewfile = true;
  #   macApps = {};
  #   casks = [ "amethyst" ];
  # };
  # launchd = {
  #   ...
  # };
}
