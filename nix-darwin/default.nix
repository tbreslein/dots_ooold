{ pkgs, ... }: {
  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [ bash dash ksh tcsh zsh ];
    loginShell = pkgs.zsh;
    systemPackages = [ pkgs.coreutils ];
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
        InitialKeyRepeat = 14;
      };
    };
  };
  fonts = {
    fontDir.enable = true;
    fonts = [ (pkgs.nerdfonts.override { fonts = [ "Meslo" "Hack" ]; }) ];
  };
}
