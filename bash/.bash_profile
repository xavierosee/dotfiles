# ~/.bash_profile - bash login shell
# Source .profile for environment variables and .bashrc

[ -f "$HOME/.profile" ] && . "$HOME/.profile"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
