# ~/.profile - login shell environment variables

# PATH
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Defaults
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox

# Source bashrc for interactive bash login shells
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ]; then
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi