{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
    hostName = "moebius";
  };
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services = {
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
    openssh.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ firefox ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  system.stateVersion = "23.05";
}
