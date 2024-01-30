{ config, ... }:

{
  conf = {
    cli = {
      enable = true;
      gitEmail = "tommy.breslein@anacision.de";
    };
    coding = {
      enable = true;
      extraShellAliases = {
        twork = "smug dots --detach; smug notes --detach; smug planning";
        pvim =
          "poetry -C ${config.home.homeDirectory}/work/planning/projects/planning_api/ run nvim";
      };
    };
    desktop = {
      enable = true;
      terminalFontSize = 18;
    };
    homeDefaults.system = "darwin";
    up.system = "darwin";
  };

  programs.alacritty.settings.window.option_as_alt = "OnlyLeft";
}
