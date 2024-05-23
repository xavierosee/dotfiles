# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Get DBT Autocomplete
source ~/.dbt-completion.bash

# User specific environment and startup programs
export TERMINAL=/usr/bin/alacritty
export EDITOR=/usr/bin/vim
