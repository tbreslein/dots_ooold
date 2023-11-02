# dots

my nix+dotfiles setup

## todo

- [ ] mac:

  - [ ] clean up these programs currently installed on the system level:

    - [ ] alacritty
    - [ ] wezterm
    - [ ] amethyst
    - [ ] rectangle
    - [ ] megacmd
    - [ ] telegram
    - [ ] whatsapp
    - [ ] firefox
    - [ ] brave

  - [ ] add packages back in through nix / nix.homebrew
  - [ ] completely remove homebrew and all of its packages
  - [ ] completely remove macports and all of its packages
  - [ ] finish the work flake
  - [x] go through and apply darwin options
  - [ ] syncthing
  - [ ] put mococlient into a launchd service

- [ ] nix in general:

  - [x] [new repo structure](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration)

    - [x] proper modules
    - [x] move plain file configurations to their respective nix modules

  - [ ] move these configs into home manager:

    - [x] dk
    - [x] hypr
    - [x] tofi (skipped it, because I want to replace it)
    - [x] waybar
    - [x] polybar
    - [ ] smug (not because of colors, but because I can abstract it a lot)

  - [ ] check out [nixvim](https://github.com/nix-community/nixvim)
    - [ ] go back to telescope
  - [ ] autorandr
