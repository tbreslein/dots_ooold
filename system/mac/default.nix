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
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      dock = {
        autohide = true;
        static-only = true;
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
