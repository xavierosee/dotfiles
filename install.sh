#!/usr/bin/env bash
# install.sh — stow all dotfiles packages, backing up conflicts
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME"
BACKUP_DIR="$TARGET_DIR/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Override map — only exceptions to the default `command -v <pkg>` check
declare -A PACKAGE_OVERRIDES=(
    [shell]=always
    [systemd]=systemd
    [wallpapers]=prompt
)

# Auto-discover packages: all directories at the repo root
mapfile -t PACKAGES < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf '%f\n' | sort)

should_install() {
    local pkg="$1"
    local override="${PACKAGE_OVERRIDES[$pkg]:-}"

    case "$override" in
        always)
            return 0
            ;;
        systemd)
            if [ -d /run/systemd/system ]; then
                return 0
            fi
            echo "[$pkg] skipped (not a systemd system)"
            return 1
            ;;
        prompt)
            read -rp "[$pkg] Install? [y/N] " answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                return 0
            fi
            echo "[$pkg] skipped (user declined)"
            return 1
            ;;
        *)
            if command -v "$pkg" &>/dev/null; then
                return 0
            fi
            echo "[$pkg] skipped (not installed)"
            return 1
            ;;
    esac
}

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
    if ! should_install "$pkg"; then
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
