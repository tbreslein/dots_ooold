{ config, ... }:

{
  conf = {
    cli = {
      enable = true;
      gitEmail = "tommy.breslein@pailot.com";
    };
    coding = {
      enable = true;
      extraShellAliases = {
        twork =
          "tmuxp load planning_docs planning_curls planning_schlogg planning_moco dots planning_work notes planning";
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
