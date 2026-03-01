# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Targets three machines: a Fedora headless home server, a Fedora Sway travel laptop, and a macOS work machine.

## Machines

| Name | Hardware | OS | Role |
|------|----------|----|------|
| `t2` | MacBook Pro 2018 (T2) | Fedora | Headless home server, Darktable library, Syncthing hub |
| `pink` | MacBook 2016 | Fedora Sway | Travel laptop, light dev |
| `macos` | MacBook Pro M5 | macOS | Work machine |
| `pixel` | Pixel tablet | Android | Manual setup only (see below) |

All Linux machines run Tailscale + Syncthing.

---

## Quick start

### Fresh machine

```bash
git clone git@github.com:xavierosee/dotfiles.git ~/dotfiles
cd ~/dotfiles
make bootstrap-t2     # on T2
make bootstrap-pink   # on pink
make bootstrap-macos  # on macOS (requires Homebrew)
```

Each `bootstrap-*` target installs packages for that machine, then calls `make install` to stow the dotfiles.

### Dotfiles only (already have packages)

```bash
make install
```

Stows all applicable packages, backs up any conflicting files to `~/.dotfiles_backup/<timestamp>/`, and runs platform-specific post-install steps (systemd units, keyd config, macOS LaunchAgent).

### Stow a single package

```bash
make stow nvim
```

---

## Repository layout

```
dotfiles/
  packages/             # bootstrap scripts (not stowed)
    common-linux.sh     # shared Fedora base
    t2.sh               # T2: adds COPR, Syncthing system service, Cockpit
    pink.sh             # pink: Syncthing user service
    macos.sh            # macOS: Homebrew packages
  bash/                 # .bash_profile, .bashrc
  fcitx5/               # CJK input (fcitx5 + pinyin)
  foot/                 # terminal emulator
  git/                  # git config + global ignore
  keyd/                 # keyboard remapping (system-wide, not stowed to $HOME)
  macos/                # macOS LaunchAgent for ssh-add
  mimeapps/             # default app associations (Linux only)
  nvim/                 # Neovim config
  rofi/                 # application launcher
  session/              # systemd environment.d (ssh-agent socket)
  shell/                # .profile + .aliases (POSIX, shared by bash/zsh)
  stow/                 # .stowrc
  sway/                 # Sway window manager (config.d/ + scripts/)
  swaylock/             # lock screen
  systemd/              # logind lid-switch config (system-wide, not stowed to $HOME)
  wallpapers/           # wallpaper images
  waybar/               # status bar
```

### Package install logic

`make install` is smart about what gets stowed:

- `keyd`, `systemd`, `packages` — never stowed to `$HOME` (handled separately)
- `shell`, `session` — always stowed
- `mimeapps` — Linux only
- `macos` — macOS only
- `wallpapers` — interactive prompt
- Everything else — stowed only if the corresponding command exists on the system (e.g. `nvim`, `sway`, `foot`)

---

## What's configured

### Shell

- **`.profile`** — login environment: PATH (`~/bin`, `~/.local/bin`, `~/.npm-global`), XDG base dirs, defaults (`EDITOR=nvim`, `BROWSER=firefox`), fcitx5 env vars
- **`.bashrc`** — 100k-line history with timestamps, fast git prompt in PS1, case-insensitive completion, lazy-loads fzf and pyenv
- **`.aliases`** — common aliases including OS-aware `ls`/`rm`, `gs/gd/ga/gl/glg` git shortcuts, `vim→nvim`, `ping→prettyping`, `top→htop`, `sc`/`scu`/`jc` systemctl/journalctl shortcuts (Linux)

### Sway

Config is split into layered modules under `sway/.config/sway/config.d/`:

| File | Purpose |
|------|---------|
| `10-variables.conf` | Modifier key, terminal, launcher, vim-direction keys |
| `20-hardware.conf` | Display (eDP-1, 2560×1600 @ 1.5×), touchpad |
| `50-autostart.conf` | ssh-agent socket, fcitx5 daemon |
| `60-bindings-*.conf` | Window/workspace/default keybindings |
| `70-window-rules.conf` | Per-app rules |
| `80-theme.conf` | Font (JuliaMono SemiBold 10pt), borders |
| `90-bar.conf` | waybar |
| `90-swayidle.conf` | Idle/power management via `power-idle.sh` |

**Modifier key:** Super (`$mod`)

Key bindings: `$mod+Return` terminal · `$mod+space` launcher · `$mod+Shift+b` browser · `$mod+Shift+s` lock · `$mod+[hjkl]` focus · `$mod+f` fullscreen · `$mod+r` resize mode

### Sway scripts

**`display-setup.sh`** — Hotplug handler. When an external monitor is connected, moves all workspaces to it, disables the internal display, and picks the right wallpaper based on aspect ratio (ultrawide ≥2.0 → `uw.jpg`, standard → `coe33.jpg`). Reverts on disconnect.

**`power-idle.sh`** — Power-aware idle manager. Reads AC adapter state and adjusts swayidle timeouts:
- **AC**: no screen lock, no display off
- **Battery**: lock at 5min, displays off at 10min, lock before sleep

Touch Bar brightness is managed on machines that have it (guarded with a `-w` check so it's safe on the 2016 MacBook).

### Keyboard (keyd)

System-wide remapping via keyd:
- `CapsLock` → `Control`
- `Right Alt` → `Escape`

Installed to `/etc/keyd/default.conf` by `make keyd` (requires sudo).

### Input method (fcitx5)

Configured for Simplified Chinese with Ziranma Shuangpin. Hotkeys:
- `Super+Space` — switch input group
- `Alt+Shift_L` / `Alt+Shift_R` — cycle forward/backward
- `Ctrl+Shift+F` — toggle Simplified↔Traditional (OpenCC)

`profile` (which IM is active) is intentionally **not tracked in git** — fcitx5 rewrites it on every switch.

### Git

Notable config:
- Delta pager with side-by-side diffs and line numbers
- `https://github.com/` URLs rewritten to SSH automatically
- Pull via interactive rebase
- Useful aliases: `ap` (add --patch), `sweep` (clean merged branches), `lg` (log graph), `pf` (push --force-with-lease)

### SSH

- `AddKeysToAgent yes` globally
- **Linux**: ssh-agent runs as a systemd user socket (`ssh-agent.socket`); socket path set via `environment.d/ssh-agent.conf`
- **macOS**: ssh-add LaunchAgent loads keys from Keychain on login (`com.user.ssh-add.plist`)

### Tailscale + Syncthing

Installed on all machines. After bootstrapping:

```bash
sudo tailscale up        # authenticate (Linux)
# open Tailscale.app    # authenticate (macOS)
```

Syncthing web UI: `http://localhost:8384`

On T2, Syncthing runs as a **system service** (`syncthing@$USER`) so it stays active even without a login session. On pink it runs as a **user service**.

### Cockpit (T2 only)

Web-based machine management at `http://localhost:9090`, also reachable via Tailscale. Enabled by `bootstrap-t2`.

---

## Pixel tablet (manual)

Install from Play Store:
- **Tailscale**
- **Syncthing-Fork**
- **Jellyfin**
- **Termux**

---

## Notable files not tracked in git

| File | Reason |
|------|--------|
| `fcitx5/.config/fcitx5/profile` | Runtime state — fcitx5 rewrites it on every input method switch |

---

## Adding a new package

1. Create the directory with the target path structure mirroring `$HOME` (e.g. `myapp/.config/myapp/config`)
2. Run `make stow myapp`

If `myapp` is not a known command, add it as a special case in the Makefile's `install` target (like `shell` or `mimeapps`).
