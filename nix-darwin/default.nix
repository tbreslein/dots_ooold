{ pkgs, ... }: {
  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [ bash dash ksh tcsh zsh ];
    loginShell = pkgs.zsh;
    systemPackages = [ pkgs.coreutils pkgs.alacritty ];
  };
  nix = {
    useDaemon = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
      dock.autohide = true;
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 10;
      };
    };
  };
  fonts = {
    fontDir.enable = true;
    fonts = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
  };
  # homebrew = {
  #     enable = true;
  #     caskArgs.no_quarantine = true;
  #     global.brewfile = true;
  #     macApps = {};
  #     casks = [ "amethyst" ];
  # };
}
