bindkey -v # vim mode
export KEYTIMEOUT=1
bindkey -v '^?' backward-delete-char

setopt extendedglob nomatch menucomplete
unsetopt BEEP
stty stop undef # disable ctrl-s freezing the terminal
zle_highlight=('paste:none') # stop highlighting pasted text

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search

export FZF_DEFAULT_OPTS='--height 40%'
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

zstyle :compinstall filename "$ZDOTDIR/.zshrc"
zstyle ':completion:*' menu select
autoload -Uz compinit
_comp_options+=(globdots)
compinit

export DISABLE_AUTO_TITLE=true

alias gs="git status"
alias gc="git commit"
alias gca="git commit"
alias gcm="git commit -m"
alias gcam="git commit -am"
alias gl="git pull"
alias gp="git push"
alias gpu="git push -u"
alias gpf="git push --force-with-lease"
alias lg="lazygit"
alias cp="cp -i"
alias rm="rm -i"
alias mv="mv -i"
alias ls="exa"
alias ll="exa -l"
alias la="exa -la"
alias lla="exa -lla"
alias vim="nvim"
alias axbrew="arch -x86_64 /usr/local/Homebrew/bin/brew"
alias pacmanclean="sudo pacman -Qtdq | sudo pacman -Rns -"
alias twork="smug dots --detach; smug planning"
command -v "go-task" >/dev/null && alias task="go-task"

export ZAP_DIR="$HOME/.local/share/zap"
[[ ! -d "$ZAP_DIR" ]] && {
    git clone https://github.com/zap-zsh/zap.git "$ZAP_DIR" > /dev/null 2>&1
}
[[ -f "$ZAP_DIR/zap.zsh" ]] && {
    source "$ZAP_DIR/zap.zsh"
    plug "zsh-users/zsh-autosuggestions"
    plug "zsh-users/zsh-syntax-highlighting"
}

function up-all {
    zap update all
    [[ ! -d "$HOME/.tmux/plugins/tpm" ]] && {
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" > /dev/null 2>&1
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    }
    $HOME/.tmux/plugins/tpm/bin/update_plugins all
    rustup up
    CC=gcc nvim --headless "+Lazy! sync" +qa
}

function up-arch {
    pushd "$HOME/dots"
    if git diff-index --quiet HEAD --; then
        git pull
        command -v pacman >/dev/null && "$HOME/dots/scripts/up-pacman" || echo "Error: This isn't arch, btw"
        up-all
    else
        echo "Error: dots has unmerged changes!"
    fi
    popd
}

function up-mac {
    pushd "$HOME/dots"
    if git diff-index --quiet HEAD --; then
        git pull
        up-all
        npm update -g
        HOMEBREW_NO_INSTALL_CLEANUP=1 brew update && HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade
        brew cleanup
        HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew update && HOMEBREW_NO_INSTALL_CLEANUP=1 axbrew upgrade
        axbrew cleanup
        poetry self update
    else
        echo "Error: dots has unmerged changes!"
    fi
    popd
}

# >>> pyenv setup
if [[ $(uname) = "Darwin" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    command -v pyenv >/dev/null && eval "$(pyenv init --path --no-rehash)" || true
fi
# <<< pyenv setup

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
