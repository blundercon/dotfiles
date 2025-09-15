.PHONY: dirs stow bootstrap backup clean full-setup update \
        list-dirs add-dir remove-dir list-stow add-stow remove-stow

# Load dirs and stow packages dynamically
DIRS := $(shell grep -v '^\s*#' dirs.conf | grep -v '^\s*$$')
STOW_PKGS := $(shell grep -v '^\s*#' stow.conf | grep -v '^\s*$$')

dirs:
	@echo "📂 Ensuring directories from dirs.conf..."
	mkdir -p $(DIRS)
	chmod 700 ~/.ssh ~/.gnupg 2>/dev/null || true
	@echo "✅ Directories ensured"

stow:
	@echo "🔗 Stowing packages from stow.conf..."
	cd stow && stow --adopt $(STOW_PKGS)
	@echo "✅ Dotfiles symlinked"

unstow:
	@echo "❌ Unstowing packages from stow.conf..."
	cd stow && stow -D $(STOW_PKGS)
	@echo "✅ Dotfiles unstowed"

bootstrap: dirs stow
	@if [ -x ./bootstrap.sh ]; then ./bootstrap.sh; else echo '⚠️ No bootstrap.sh found'; fi
	@echo "✅ Packages/bootstrap complete"

backup:
	@if [ -x ./backup.sh ]; then ./backup.sh; else echo '⚠️ No backup.sh found'; fi
	@echo "✅ Package list backup complete"

clean: unstow
	@echo "✅ Cleanup complete"

update:
	git pull --rebase --autostash
	$(MAKE) full-setup

full-setup: dirs stow bootstrap backup
	@echo "🎉 Full environment setup finished (idempotent run)"

# --- Helpers for dirs.conf management ---
list-dirs:
	@echo "📂 Directories tracked in dirs.conf:"; \
	echo "$(DIRS)" | tr ' ' '\n'

add-dir:
	@if [ -z "$(DIR)" ]; then \
		echo "❌ Usage: make add-dir DIR=~/.newdir"; \
	else \
		echo "$(DIR)" >> dirs.conf; \
		echo "✅ Added $(DIR) to dirs.conf"; \
	fi

remove-dir:
	@if [ -z "$(DIR)" ]; then \
		echo "❌ Usage: make remove-dir DIR=~/.newdir"; \
	else \
		grep -v "^$(DIR)$$" dirs.conf > dirs.conf.tmp && mv dirs.conf.tmp dirs.conf; \
		echo "✅ Removed $(DIR) from dirs.conf"; \
	fi

# --- Helpers for stow.conf management ---
list-stow:
	@echo "🔗 Stow packages tracked in stow.conf:"; \
	echo "$(STOW_PKGS)" | tr ' ' '\n'

add-stow:
	@if [ -z "$(PKG)" ]; then \
		echo "❌ Usage: make add-stow PKG=package"; \
	else \
		echo "$(PKG)" >> stow.conf; \
		echo "✅ Added $(PKG) to stow.conf"; \
	fi

remove-stow:
	@if [ -z "$(PKG)" ]; then \
		echo "❌ Usage: make remove-stow PKG=package"; \
	else \
		grep -v "^$(PKG)$$" stow.conf > stow.conf.tmp && mv stow.conf.tmp stow.conf; \
		echo "✅ Removed $(PKG) from stow.conf"; \
	fi
