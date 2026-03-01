#!/bin/sh
# Bootstrap script for pink (MacBook 2016, Fedora Sway, travel machine)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common-linux.sh"

# Install Syncthing
sudo dnf install -y syncthing

# Enable as user service (not system-wide — laptop, not a server)
systemctl --user enable --now syncthing

echo ""
echo ">>> Syncthing web UI: http://localhost:8384"
echo ">>> Note: appletb_backlight path in power-idle.sh is guarded by a -w check — safe on this 2016 MacBook (no Touch Bar)."
