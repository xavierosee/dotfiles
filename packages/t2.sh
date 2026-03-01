#!/bin/sh
# Bootstrap script for T2 (MacBook Pro 2018, Fedora, headless home server)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common-linux.sh"

# Add T2 COPR (idempotent: -y skips the confirmation prompt)
sudo dnf -y copr enable t2linux/t2linux

# Install T2 firmware + server packages
sudo dnf install -y apple-t2-firmware syncthing cockpit

# Enable services
sudo systemctl enable --now "syncthing@$USER"
sudo systemctl enable --now cockpit.socket

echo ""
echo ">>> Cockpit web UI: http://localhost:9090 (also accessible via Tailscale IP)"
echo ">>> Syncthing web UI: http://localhost:8384"
