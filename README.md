# Dotfiles Repo

This repo stores:
- Config files managed via GNU Stow
- Package lists (brew, apt, snap, flatpak, etc.)
- Backup + bootstrap scripts

## Usage
- `make backup` → update package lists and push
- `make bootstrap` → restore packages and symlink configs
