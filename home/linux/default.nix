{ userConfig, ... }:

{
  home.homeDirectory = "/home/${userConfig.name}";
}
