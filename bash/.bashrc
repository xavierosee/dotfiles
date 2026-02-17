# ~/.bashrc - interactive bash configuration

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# -----------------------------------------------------
# History
# -----------------------------------------------------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=100000
HISTFILESIZE=200000
HISTTIMEFORMAT="%F %T  "
shopt -s histappend

# -----------------------------------------------------
# Shell Options
# -----------------------------------------------------
shopt -s checkwinsize
shopt -s globstar
shopt -s cdspell        # autocorrect minor cd typos
shopt -s direxpand      # expand variables in path completion
shopt -s autocd         # type a directory name to cd into it

# Tab completion ignores case
bind 'set completion-ignore-case on'

# -----------------------------------------------------
# Colors
# -----------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# -----------------------------------------------------
# Prompt (lightweight git info)
# -----------------------------------------------------
__fast_git_prompt() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    local dirty
    git diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty='*'
    echo " ${branch}${dirty}"
}

PS1='\n\u@\h:\[\e[1;36m\]\w\[\e[0;35m\]$(__fast_git_prompt)\[\e[0m\]\n\$ '

# -----------------------------------------------------
# Aliases
# -----------------------------------------------------
[ -f "$HOME/.aliases" ] && . "$HOME/.aliases"

# -----------------------------------------------------
# Completions
# -----------------------------------------------------
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    fi
fi

# -----------------------------------------------------
# Tool Integrations (lazy-loaded where possible)
# -----------------------------------------------------

# fzf
[ -f "$HOME/.fzf.bash" ] && . "$HOME/.fzf.bash"

# pyenv (lazy — only init when first called)
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv() {
        unset -f pyenv
        eval "$(command pyenv init -)"
        pyenv "$@"
    }
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
