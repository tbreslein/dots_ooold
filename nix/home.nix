{ config, pkgs, user_name, ... }: {
  nixpkgs.config.allowUnfree = true;
  home = {
    username = user_name;
    stateVersion = "23.05";
    packages = [
      # coding
      pkgs.gcc
      pkgs.neovim
      pkgs.statix
      pkgs.nil
      pkgs.alejandra
      pkgs.nixfmt

      # cli
      pkgs.fzf
    ];

    file = {
      nvim = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dots/config/nvim";
        target = "${config.home.homeDirectory}/.config/nvim";
      };
    };

    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/tommy/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
    sessionVariables = {
      # EDITOR = "emacs";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
