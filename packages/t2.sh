#!/bin/sh
# Bootstrap script for T2 (MacBook Pro 2018, Fedora, headless home server)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common-linux.sh"

# Set hostname
sudo hostnamectl set-hostname t2

# Add T2 COPR (idempotent: -y skips the confirmation prompt)
# May fail if t2linux COPR doesn't support this Fedora version yet
sudo dnf -y copr enable t2linux/t2linux || echo "Warning: t2linux COPR not available for this Fedora version, skipping firmware"

# Install T2 firmware + server packages (--skip-unavailable in case firmware isn't in COPR yet)
sudo dnf install -y --skip-unavailable apple-t2-firmware syncthing cockpit

# Enable services
sudo systemctl enable --now "syncthing@$USER"
sudo systemctl enable --now cockpit.socket

echo ""
echo ">>> Cockpit web UI: http://localhost:9090 (also accessible via Tailscale IP)"
echo ">>> Syncthing web UI: http://localhost:8384"
