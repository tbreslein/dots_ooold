# dots

My nix+dotfiles setup

## Structure

It is subdivided into modules which provide new configuration options for
basic nixos, nix-darwin and home manager.

### Modules

All modules outside of `modules/system` are home manager modules.
The system modules in turn are meant for nixos and nix-darwin and are mostly
separated into configuration for different systems and architectures.

The home modules are separated according to certain roles.
Everything coding related is in the `coding` module, desktop stuff is in the
`desktop` module, etc.

### Hosts

These are the host specific configurations.
They simply use my custom modules to configure themselves + very host specific
configuration like filesystem devices and such.
