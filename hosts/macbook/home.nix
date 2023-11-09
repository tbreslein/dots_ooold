_:

{
  conf = {
    cli = {
      enable = true;
      gitEmail = "tommy.breslein@anacision.de";
    };
    coding = {
      enable = true;
      extraShellAliases.twork =
        "smug dots --detach; smug notes --detach; smug planning";
    };
    desktop = {
      enable = true;
      terminalFontSize = 18;
    };
    homeDefaults.system = "darwin";
    up = {
      system = "darwin";
      additionalRoles = [ "coding" ];
    };
  };
}
