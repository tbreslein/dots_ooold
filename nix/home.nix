{ config, pkgs, user_name, mk_config, ... }: {
  nixpkgs.config.allowUnfree = true;
  home = {
    username = user_name;
    stateVersion = "23.05";
    packages = [
      # coding
      pkgs.gcc
      pkgs.neovim
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.yamllint
      pkgs.prettierd
      pkgs.statix
      pkgs.nil
      pkgs.nixfmt

      # cli
      pkgs.fzf
      pkgs.tmux
    ];

    file = {
      nvim = mk_config config "nvim";
      tmux = mk_config config "tmux";
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
  programs = {
    home-manager.enable = true;
    eza = { enable = true; };
  };
}
