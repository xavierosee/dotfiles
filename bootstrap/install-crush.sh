#!/usr/bin/env bash
# One-time host setup for Crush + Tensorix + LiteLLM proxy.
# Idempotent — safe to re-run.
# Does NOT install or copy any secret. Secrets must be added to `pass` separately.
# Run from inside the dotfiles repo root.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

require_pass_entry() {
  if ! command -v pass >/dev/null 2>&1; then
    echo "ERROR: install 'pass' first (sudo dnf install -y pass) and initialize a GPG key."
    echo "       Then: pass insert api/tensorix"
    exit 1
  fi
  if ! pass show api/tensorix >/dev/null 2>&1; then
    echo "ERROR: 'api/tensorix' missing from password store."
    echo "       Run: pass insert api/tensorix"
    exit 1
  fi
}

install_charm_repo() {
  if [ ! -f /etc/yum.repos.d/charm.repo ]; then
    echo "[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key" | sudo tee /etc/yum.repos.d/charm.repo
  fi
}

install_packages() {
  sudo dnf install -y crush pipx bash-language-server nodejs npm redis pass
}

install_lsps() {
  pipx ensurepath
  pipx install pyright || pipx upgrade pyright
  # Pre-warm npx cache so first Crush launch is fast
  npx -y typescript-language-server --version >/dev/null
  npx -y yaml-language-server --version >/dev/null
}

setup_litellm_venv() {
  local venv_dir="$HOME/.local/litellm-proxy"
  if [ ! -d "$venv_dir/venv" ]; then
    mkdir -p "$venv_dir"
    python3 -m venv "$venv_dir/venv"
  fi
  "$venv_dir/venv/bin/pip" install --quiet --upgrade pip
  "$venv_dir/venv/bin/pip" install --quiet 'litellm[proxy]'
}

enable_redis() {
  sudo systemctl enable --now redis
}

stow_packages() {
  command -v stow >/dev/null 2>&1 || { echo "ERROR: stow not found — run: sudo dnf install stow"; exit 1; }
  stow -d "$DOTFILES_DIR" -t "$HOME" -R crush litellm
  echo "crush and litellm packages stowed"
}

enable_litellm_user_service() {
  systemctl --user daemon-reload
  systemctl --user enable --now litellm-proxy.service
}

main() {
  require_pass_entry
  install_charm_repo
  install_packages
  install_lsps
  setup_litellm_venv
  enable_redis
  stow_packages
  enable_litellm_user_service
  echo
  echo "Bootstrap complete."
  echo "   Run 'systemctl --user status litellm-proxy.service' to verify."
  echo "   Then 'crush' in any project directory."
}

main "$@"
