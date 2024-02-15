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
          "tmuxp load home dots notes planning_docs planning_curls planning_schlogg planning_moco planning_work planning";
        pvim =
          "poetry -C ${config.home.homeDirectory}/work/planning/projects/planning_api/ run nvim";
      };
    };
    desktop = {
      enable = true;
      terminalFontSize = 17;
    };
    homeDefaults.system = "darwin";
    up.system = "darwin";
  };

  programs.alacritty.settings.window.option_as_alt = "OnlyLeft";
}
