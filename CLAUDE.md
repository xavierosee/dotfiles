# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed with GNU Stow, targeting three machines:

| Name | OS | Role |
|------|----|------|
| `t2` | Fedora (headless) | Home server |
| `pink` | Fedora + Sway | Travel laptop |
| `macos` | macOS (Apple Silicon) | Work machine |

## Key commands

```bash
# Fresh machine bootstrap
make bootstrap-t2      # t2
make bootstrap-pink    # pink
make bootstrap-macos   # macOS (requires Homebrew)

# Stow all applicable dotfiles (with conflict backup)
make install

# Stow a single package
make stow <package>    # e.g. make stow nvim

# System-level installs (called automatically by make install when applicable)
make keyd              # requires sudo — installs /etc/keyd/default.conf
make sddm              # requires sudo — installs theme + config
make systemd           # requires sudo — installs logind config, enables ssh-agent.socket
make macos             # loads ssh-add LaunchAgent (macOS only)
```

## How stowing works

`make install` auto-detects what to stow:
- `keyd`, `sddm`, `systemd`, `packages` — never stowed to `$HOME` (handled by their own targets)
- `shell`, `session` — always stowed
- `mimeapps` — Linux only
- `macos` — macOS only
- `wallpapers` — interactive prompt
- Everything else — stowed only if the corresponding command exists (e.g. `nvim`, `sway`, `foot`)

Conflicting files are backed up to `~/.dotfiles_backup/<timestamp>/` before stowing.

## Adding a new package

1. Create a directory whose structure mirrors `$HOME` (e.g. `myapp/.config/myapp/config`)
2. Run `make stow myapp`

If the package name isn't an installed command, add a special case in the `install` target (like `shell` or `mimeapps`).

## Notable non-tracked files

- `fcitx5/.config/fcitx5/profile` — fcitx5 rewrites this at runtime on every input method switch; don't track it.

## Sway config structure

Config lives in `sway/.config/sway/config.d/` and is loaded in numbered order:
- `10-variables.conf` — modifier key (`$mod` = Super), terminal, launcher
- `20-hardware.conf` — display (eDP-1, 2560×1600 @ 1.5×), touchpad
- `50-autostart.conf` — ssh-agent socket, fcitx5
- `60-bindings-*.conf` — keybindings
- `70-window-rules.conf` — per-app rules
- `80-theme.conf` — font (JuliaMono SemiBold 10pt), borders
- `90-bar.conf` / `90-swayidle.conf` — waybar and idle/power management

## SSH agent

- **Linux**: systemd user socket (`ssh-agent.socket`); socket path via `session/.config/environment.d/ssh-agent.conf`
- **macOS**: LaunchAgent in `macos/Library/LaunchAgents/com.user.ssh-add.plist` loads keys from Keychain at login
