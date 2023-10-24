# setup on debian

run base install without a desktop env

```bash
# log into root

apt install sudo curl wget htop vim awesome awesome-extra xinit git alacritty wireplumber pipewire-pulse pipewire-alsa network-manager
systemctl disable networking.service
systemctl enable NetworkManager
usermod -a -G sudo tommy

# log in as tommy and install nix
sh <(curl -L https://nixos.org/nix/install) --daemon
source ~/.bashrc

# back to root
echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
systemctl restart nix-daemon.service

# back to tommy
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
nix-channel --update

# clone my dots and home-manager switch --flake on it
```

## todo

- on mac: save dots/{zsh,pypoetry,wezterm} before changing dots
