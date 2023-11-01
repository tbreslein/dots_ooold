{ pkgs, ... }: {
  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [ bash zsh ];
    loginShell = pkgs.zsh;
  };
  nix = {
    useDaemon = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  systemPackages = [ pkgs.coreutils ];
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
