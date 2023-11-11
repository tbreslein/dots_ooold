_:

{
  conf = {
    cli.enable = true;
    coding.enable = true;
    desktop = {
      enable = true;
      terminalFontSize = 14;
    };
    homeDefaults.system = "linux";
    up = {
      system = "nixos";
      additionalRoles = [ "coding" ];
    };
  };
}
