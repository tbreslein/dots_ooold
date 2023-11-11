{ userName, ... }:

{
  options.conf.systemDefaults = { };

  imports = [ <nixos-wsl/modules> ];
  config = {
    wsl = {
      enable = true;
      defaultUser = userName;
    };
  };
}
