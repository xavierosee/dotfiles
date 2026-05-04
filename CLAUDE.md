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

### Always-stowed packages (no command check)

- `shell`, `session`, `bin` — stowed unconditionally on all Linux machines

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

## Machine state — pink

Known quirks and deferred work for the travel laptop (MacBook9,1 / Early 2016 12"):

**Waybar startup delay** (`waybar/.config/systemd/user/waybar.service.d/delay.conf`)
Waybar crashed 5× on 2026-05-02 due to a hotplug race: sway removed `eDP-1` while waybar was mid-init on a dual-monitor session. Fixed with a 2-second `ExecStartPre` delay. This is an upstream waybar bug — not a config issue.

**Bluetooth firmware — deferred**
Chip: BCM4350C0 on SPI (`hci_uart_bcm serial1-0`). Kernel wants `brcm/BCM.hcd` but no distro package provides it for this model. Must be extracted from macOS: `/usr/share/firmware/bluetooth/` on a macOS volume for MacBook9,1, then placed at `/lib/firmware/brcm/BCM.hcd`. Bluetooth is non-functional until then.

**Blueman stale iterator**
blueman 2.4.6-4.fc43 crashes with `TypeError: Invalid type` in `GenericList.py:109` when a previously-paired device is absent. Workaround: remove and re-pair the offending device in Bluetooth settings. Known upstream bug, no patch merged.

**ABRT triage framework** (`bin/` package)
Monthly cron on the 1st calls `abrt-triage-cron` → saves a Claude-generated report to `~/.local/share/abrt-triage/` and sends a desktop notification. Run `abrt-review` interactively to triage and delete resolved reports.

## SSH agent

- **Linux**: systemd user socket (`ssh-agent.socket`); socket path via `session/.config/environment.d/ssh-agent.conf`
- **macOS**: LaunchAgent in `macos/Library/LaunchAgents/com.user.ssh-add.plist` loads keys from Keychain at login
