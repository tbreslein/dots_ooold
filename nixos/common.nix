{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "tommy" ];
      substituters = [ "https://cachix.cachix.org" ];
      trusted-public-keys =
        [ "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=" ];
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };
  security.rtkit.enable = true;
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true;
      displayManager.sddm = {
        enable = true;
        theme = "${import ./sddm-themes/sugar-dark.nix { inherit pkgs; }}";
      };
    };
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  environment = {
    sessionVariables = { NIXOS_OZONE_WL = "1"; };
    systemPackages = with pkgs; [
      vim
      wget
      curl
      unzip
      git
      killall

      # for sddm themeing
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtgraphicaleffects
    ];
  };

  sound.enable = true;
  hardware.opengl.enable = true;

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ alacritty ];
  };

  system.stateVersion = "23.05";
}