{ pkgs, lib, userConfig, ... }:

{
  sound.enable = true;
  hardware.opengl.enable = true;

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true;
      layout = "us,de";
      desktopManager.xterm.enable = false;
      displayManager = {
        sddm = {
          enable = userConfig.isWaylandWM;
          theme = "${import ./sddm-themes/sugar-dark.nix { inherit pkgs; }}";
          wayland.enable = userConfig.isWaylandWM;
        };
      };
      windowManager.dk.enable = userConfig.wm == "dk";
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

  programs = {
    dconf.enable = true;
    hyprland = lib.mkIf (userConfig.wm == "hyprland") {
      enable = true;
      xwayland.enable = true;
    };
  };
  environment = {
    sessionVariables = lib.mkIf userConfig.isWaylandWM {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland:xcb";
    };
    systemPackages = with pkgs;
      [ alacritty ] ++ (if userConfig.isWaylandWM then [
        libsForQt5.qt5.qtquickcontrols2
        libsForQt5.qt5.qtgraphicaleffects
      ] else
        [ picom-next ]);
  };
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };

  xdg.portal = {
    enable = userConfig.isWaylandWM;
    extraPortals = lib.mkIf (userConfig.wm == "hyprland")
      [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # users.users.tommy = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" "networkmanager" ];
  #   initialPassword = "qwert";
  #   shell = pkgs.zsh;
  # };

  system.stateVersion = "23.05";
}
