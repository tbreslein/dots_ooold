export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="firefox"
export TERMINAL="foot"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000
[[ -d "$XDG_DATA_HOME/zsh" ]] || mkdir -p "$XDG_DATA_HOME/zsh/"
[[ -f "$XDG_DATA_HOME/zsh/history" ]] || touch "$XDG_DATA_HOME/zsh/history"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1 # fixes thunderbird and firefox in wayland

[[ -d "$HOME/.cargo" ]] && [[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm_global/bin:$PATH"
export GOPATH="$HOME/.local/share/go"
export PATH="$HOME/.local/share/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
