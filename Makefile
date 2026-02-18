SHELL        := /bin/sh
DOTFILES_DIR := $(shell cd "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))" && pwd)
TARGET_DIR   := $(HOME)
BACKUP_DIR   := $(TARGET_DIR)/.dotfiles_backup/$(shell date +%Y%m%d_%H%M%S)
PACKAGES     := $(sort $(shell find "$(DOTFILES_DIR)" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf '%f\n'))

# Packages that aren't stowable (not targeting $HOME)
NOSTOW := keyd systemd

.PHONY: install stow keyd systemd

install:
	@command -v stow >/dev/null 2>&1 || { echo "Error: stow is not installed. Run: sudo dnf install stow"; exit 1; }
	@echo "Installing dotfiles from $(DOTFILES_DIR)"
	@echo ""
	@backup_needed=false; \
	for pkg in $(PACKAGES); do \
		skip=false; \
		case "$$pkg" in \
			keyd|systemd) skip=true ;; \
			shell) ;; \
			wallpapers) \
				printf "[$$pkg] Install? [y/N] "; \
				read answer; \
				case "$$answer" in \
					[Yy]) ;; \
					*) echo "[$$pkg] skipped (user declined)"; skip=true ;; \
				esac ;; \
			*) \
				if ! command -v "$$pkg" >/dev/null 2>&1; then \
					echo "[$$pkg] skipped (not installed)"; \
					skip=true; \
				fi ;; \
		esac; \
		if [ "$$skip" = false ]; then \
			conflicts=$$(stow -d "$(DOTFILES_DIR)" -t "$(TARGET_DIR)" -n "$$pkg" 2>&1 || true); \
			files=$$(echo "$$conflicts" | sed -n 's/.*over existing target \(.*\) since.*/\1/p'); \
			if [ -n "$$files" ]; then \
				echo "  Backing up conflicts for $$pkg..."; \
				mkdir -p "$(BACKUP_DIR)"; \
				backup_needed=true; \
				echo "$$files" | while IFS= read -r file; do \
					if [ -n "$$file" ] && [ -e "$(TARGET_DIR)/$$file" ]; then \
						mkdir -p "$$(dirname "$(BACKUP_DIR)/$$file")"; \
						mv "$(TARGET_DIR)/$$file" "$(BACKUP_DIR)/$$file"; \
						echo "    $$file -> $(BACKUP_DIR)/$$file"; \
					fi; \
				done; \
			fi; \
			stow -d "$(DOTFILES_DIR)" -t "$(TARGET_DIR)" -R "$$pkg"; \
			echo "[$$pkg] stowed"; \
		fi; \
	done; \
	echo ""; \
	echo "Done!"; \
	if [ "$$backup_needed" = true ]; then \
		echo "Backups saved to: $(BACKUP_DIR)"; \
	fi
	@if [ -d /run/systemd/system ]; then $(MAKE) systemd; else echo "[systemd] skipped (not a systemd system)"; fi
	@if command -v keyd >/dev/null 2>&1; then $(MAKE) keyd; else echo "[keyd] skipped (not installed)"; fi

systemd:
	@[ -d /run/systemd/system ] || { echo "Error: not a systemd system"; exit 1; }
	sudo mkdir -p /etc/systemd/logind.conf.d
	sudo cp "$(DOTFILES_DIR)/systemd/logind.conf.d/lid-switch.conf" /etc/systemd/logind.conf.d/lid-switch.conf
	sudo systemctl restart systemd-logind
	@echo "[systemd] logind config installed"

keyd:
	@command -v keyd >/dev/null 2>&1 || { echo "Error: keyd is not installed. Run: sudo dnf install keyd"; exit 1; }
	sudo cp "$(DOTFILES_DIR)/keyd/default.conf" /etc/keyd/default.conf
	sudo keyd reload
	@echo "[keyd] installed and reloaded"

PKG := $(word 2, $(MAKECMDGOALS))

stow:
	@test -n "$(PKG)" || { echo "Usage: make stow <package>"; exit 1; }
	@test -d "$(DOTFILES_DIR)/$(PKG)" || { echo "Error: package '$(PKG)' not found in $(DOTFILES_DIR)"; exit 1; }
	@command -v stow >/dev/null 2>&1 || { echo "Error: stow is not installed. Run: sudo dnf install stow"; exit 1; }
	@conflicts=$$(stow -d "$(DOTFILES_DIR)" -t "$(TARGET_DIR)" -n "$(PKG)" 2>&1 || true); \
	files=$$(echo "$$conflicts" | sed -n 's/.*over existing target \(.*\) since.*/\1/p'); \
	if [ -n "$$files" ]; then \
		echo "  Backing up conflicts for $(PKG)..."; \
		mkdir -p "$(BACKUP_DIR)"; \
		echo "$$files" | while IFS= read -r file; do \
			if [ -n "$$file" ] && [ -e "$(TARGET_DIR)/$$file" ]; then \
				mkdir -p "$$(dirname "$(BACKUP_DIR)/$$file")"; \
				mv "$(TARGET_DIR)/$$file" "$(BACKUP_DIR)/$$file"; \
				echo "    $$file -> $(BACKUP_DIR)/$$file"; \
			fi; \
		done; \
	fi
	@stow -d "$(DOTFILES_DIR)" -t "$(TARGET_DIR)" -R "$(PKG)"
	@echo "[$(PKG)] stowed"

# Catch the package name passed as a target so Make doesn't error
%:
	@:
