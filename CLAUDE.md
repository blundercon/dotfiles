# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles and system bootstrap repository that makes fresh machine setups reproducible and idempotent. The system uses:
- **GNU Stow** for configuration symlink management
- **Makefile** for orchestrating setup tasks
- **Package lists** to maintain consistent environments across machines
- **Automated backup** system to capture current machine state and mirror tracked directories

## Key Commands

### Primary Development Commands
- `make full-setup` - Complete idempotent environment setup (dirs + stow + bootstrap + backup)
- `make bootstrap` - Install packages from all package managers (requires dirs and stow first)
- `make backup` - Update all package lists and auto-commit changes to git
- `make update` - Pull latest changes and re-run full-setup
- `make clean` - Remove all stow symlinks

### Individual Component Commands
- `make dirs` - Create directory structure from `dirs.conf`
- `make stow` - Symlink dotfiles using GNU Stow (adopts existing configs)
- `make unstow` - Remove all stow symlinks

### Configuration Management Helpers
- `make list-dirs` - Show directories tracked in `dirs.conf`
- `make add-dir DIR=~/newpath` - Add directory to `dirs.conf`
- `make remove-dir DIR=~/path` - Remove directory from `dirs.conf`
- `make list-stow` - Show stow packages in `stow.conf`
- `make add-stow PKG=package` - Add stow package to `stow.conf`
- `make remove-stow PKG=package` - Remove stow package from `stow.conf`

### One-Shot Installation
- `curl -fsSL https://raw.githubusercontent.com/blundercon/dotfiles/main/install.sh | bash`

## Architecture

### Core Components

**Configuration Files:**
- `dirs.conf` - Defines directory structure to create
- `stow.conf` - Lists which stow packages to symlink
- Package lists: `Brewfile`, `apt-packages.list`, `snap-packages.txt`, etc.

**Scripts:**
- `install.sh` - One-shot installer for fresh machines
- `bootstrap.sh` - Cross-platform package installation
- `backup.sh` - Captures current machine state and auto-commits
- `Makefile` - Orchestrates all operations with proper dependencies

**Stow Directory Structure:**
```
stow/
├── alacritty/.config/alacritty/
├── bash/.bashrc
├── fish/.config/fish/config.fish
├── git/.gitconfig
├── nvim/.config/nvim/init.lua
├── tmux/.tmux.conf
├── vim/.vimrc
├── vscode/.config/Code/User/settings.json
├── zellij/.config/zellij/config.kdl
└── zsh/.zshrc
```

### Key Design Patterns

**Idempotent Operations:** All make targets can be run multiple times safely. The `--adopt` flag in stow allows it to take over existing configs without conflicts.

**Dependency Chain:**
- `full-setup` depends on: `dirs` → `stow` → `bootstrap` → `backup`
- `bootstrap` requires `dirs` and `stow` to be completed first
- `backup` runs package list dumps and auto-commits changes

**Cross-Platform Support:** `bootstrap.sh` detects available package managers (brew, apt, snap, flatpak, pip, npm, cargo) and installs accordingly.

**Configuration Management:** Uses two config files (`dirs.conf`, `stow.conf`) to define what gets managed, with helper make targets to modify them safely.

## Testing

Test the bootstrap process in containers:
```bash
docker run -it ubuntu:24.04 bash
# inside container
apt update && apt install -y curl
curl -fsSL https://raw.githubusercontent.com/blundercon/dotfiles/main/install.sh | bash
```

## Important Notes

- All operations are designed to be **idempotent** - safe to run repeatedly
- The system **auto-commits** changes during backup operations
- **Stow adopts** existing configs on first run, preventing conflicts
- **Directory permissions** are automatically set for `~/.ssh` and `~/.gnupg` (chmod 700)
- **Authentication** uses GitHub CLI (`gh`) for repo access