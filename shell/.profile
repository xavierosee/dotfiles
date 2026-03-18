# ~/.profile - login shell environment variables

# PATH
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.npm-global" ] && PATH="$HOME/.npm-global:$PATH"
[ -d "$HOME/.nom-global/bin" ] && PATH="$HOME/.nom-global/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Defaults
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox

# Input method (fcitx5)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Tool config
export BAT_THEME="GitHub"

# Source bashrc for interactive bash login shells
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ]; then
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

# Machine-local secrets (not tracked in git)
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"

