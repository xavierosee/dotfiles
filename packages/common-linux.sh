#!/bin/sh
# Common packages for all Fedora machines
set -e

# Add Tailscale repo (skip if already present)
if [ ! -f /etc/yum.repos.d/tailscale.repo ]; then
    sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
fi

# Install base packages
sudo dnf install -y \
    stow neovim git git-delta sway waybar swaylock swayidle rofi foot fcitx5 fcitx5-chinese-addons keyd \
    bat fzf htop jq upower python3 \
    pipewire wireplumber pipewire-pulseaudio pavucontrol wl-clipboard grim slurp xdg-desktop-portal-wlr power-profiles-daemon brightnessctl \
    firefox zathura zathura-pdf-poppler darktable tailscale

# Install prettyping (not in Fedora repos)
mkdir -p "$HOME/.local/bin"
curl -Lo "$HOME/.local/bin/prettyping" https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
chmod +x "$HOME/.local/bin/prettyping"

# Enable Tailscale
sudo systemctl enable --now tailscaled

echo ""
echo ">>> Run 'sudo tailscale up' to authenticate this machine with Tailscale."
