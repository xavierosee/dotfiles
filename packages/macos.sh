#!/bin/sh
# Bootstrap script for macOS (MacBook Pro M5, work machine)
set -e

# Require Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is not installed. Install it from https://brew.sh then re-run."
    exit 1
fi

# Set hostname
sudo scutil --set HostName macos
sudo scutil --set ComputerName macos
sudo scutil --set LocalHostName macos

brew install neovim git git-delta bat fzf htop jq prettyping

brew install --cask tailscale

echo ""
echo ">>> Open Tailscale.app and sign in to authenticate this machine."
