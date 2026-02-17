#!/usr/bin/env bash
# install.sh — stow all dotfiles packages, backing up conflicts
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME"
BACKUP_DIR="$TARGET_DIR/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

PACKAGES=(
    stow
    shell
    bash
    git
    nvim
    sway
    swaylock
    wallpapers
    waybar
)

backup_conflicts() {
    local pkg="$1"

    # Dry-run stow and capture conflicts
    local output
    output=$(stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" -n "$pkg" 2>&1 || true)

    # Extract conflicting file paths
    local files
    files=$(echo "$output" | sed -n 's/.*over existing target \(.*\) since.*/\1/p')

    if [ -z "$files" ]; then
        return
    fi

    echo "  Backing up conflicts for $pkg..."
    mkdir -p "$BACKUP_DIR"

    while IFS= read -r file; do
        if [ -n "$file" ] && [ -e "$TARGET_DIR/$file" ]; then
            local backup_path="$BACKUP_DIR/$file"
            mkdir -p "$(dirname "$backup_path")"
            mv "$TARGET_DIR/$file" "$backup_path"
            echo "    $file -> $BACKUP_DIR/$file"
        fi
    done <<< "$files"
}

echo "Installing dotfiles from $DOTFILES_DIR"
echo ""

# Check stow is installed
if ! command -v stow &>/dev/null; then
    echo "Error: stow is not installed. Run: sudo dnf install stow"
    exit 1
fi

for pkg in "${PACKAGES[@]}"; do
    if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
        echo "[$pkg] skipped (not found)"
        continue
    fi

    backup_conflicts "$pkg"
    stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" -R "$pkg"
    echo "[$pkg] stowed"
done

echo ""
echo "Done!"
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi