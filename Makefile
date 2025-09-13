.PHONY: dirs stow bootstrap backup clean full-setup

dirs:
	mkdir -p ~/bin \
	         ~/code/personal \
	         ~/code/work \
	         ~/code/experiments \
	         ~/docs \
	         ~/downloads \
	         ~/media \
	         ~/tmp \
	         ~/.config \
	         ~/.local/bin \
	         ~/.local/share \
	         ~/.ssh \
	         ~/.gnupg
	chmod 700 ~/.ssh ~/.gnupg
	@echo "✅ Directories ensured"

stow:
	# Adopt existing configs if they aren't symlinks yet
	cd stow && stow --adopt */
	@echo "✅ Dotfiles symlinked"

bootstrap: dirs stow
	@if [ -x ./bootstrap.sh ]; then ./bootstrap.sh; else echo '⚠️ No bootstrap.sh found'; fi
	@echo "✅ Packages/bootstrap complete"

backup:
	@if [ -x ./backup.sh ]; then ./backup.sh; else echo '⚠️ No backup.sh found'; fi
	@echo "✅ Package list backup complete"

clean:
	cd stow && stow -D */
	@echo "✅ Symlinks removed"

full-setup: dirs stow bootstrap backup
	@echo "🎉 Full environment setup finished (idempotent run)"

