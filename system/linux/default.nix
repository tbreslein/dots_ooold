{ pkgs, ... }:

{
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
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

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "qwert";
    shell = pkgs.zsh;
  };

  system.stateVersion = "23.05";
}
