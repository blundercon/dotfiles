# 📦 blundercon/dotfiles

My personal **dotfiles + system bootstrap** setup.  
This repo makes a fresh machine setup reproducible and idempotent.  

---

## 🚀 One-Shot Install

On a fresh machine, run:

    curl -fsSL https://raw.githubusercontent.com/blundercon/dotfiles/main/install.sh | bash

This will:

1. Install prerequisites (`git`, `gh`, `make`, `stow`)  
2. Clone or update this repo (`blundercon/dotfiles`)  
3. Run `make full-setup` which ensures:  
   - ✅ Base directory structure (`~/bin`, `~/code`, `~/docs`, etc.)  
   - ✅ Config symlinks via GNU Stow  
   - ✅ Package installation (brew, apt, snap, flatpak, pip, npm, cargo)  
   - ✅ Package list backup  

Result: full environment bootstrap in one command ⚡  

---

## 📂 Repo Structure

    dotfiles/
    ├── install.sh              # one-shot installer (curl | bash entrypoint)
    ├── Makefile                # orchestrates dirs, stow, bootstrap, backup
    ├── bootstrap.sh            # installs packages
    ├── backup.sh               # saves package lists + pushes
    ├── dirs.conf               # directories to create
    ├── stow.conf               # stow packages to manage
    ├── Brewfile                # Homebrew packages (macOS)
    ├── apt-packages.list       # apt packages (Debian/Ubuntu)
    ├── snap-packages.txt       # snap packages
    ├── flatpak-packages.txt    # flatpak apps
    ├── requirements.txt        # Python packages
    ├── npm-global.txt          # Node global packages
    ├── cargo-list.txt          # Rust packages
    └── stow/                   # all configs managed via GNU Stow
        ├── alacritty/.config/alacritty/
        ├── bash/.bashrc
        ├── fish/.config/fish/
        ├── git/.gitconfig
        ├── nvim/.config/nvim/
        ├── tmux/.tmux.conf
        ├── vim/.vimrc
        ├── vscode/.config/Code/User/
        ├── zellij/.config/zellij/
        └── zsh/.zshrc

---

## 🛠️ Makefile Targets

### Core Targets

- `make dirs` → Ensure base directories exist
- `make stow` → Symlink configs (adopts existing configs on first run)
- `make bootstrap` → Install packages via `bootstrap.sh`
- `make backup` → Update package lists and push
- `make full-setup` → Run everything (idempotent full setup)
- `make clean` → Remove stow symlinks
- `make update` → Pull latest repo changes and re-run full setup

### Configuration Management Helpers

- `make list-dirs` → Show directories tracked in `dirs.conf`
- `make add-dir DIR=~/newpath` → Add directory to `dirs.conf`
- `make remove-dir DIR=~/path` → Remove directory from `dirs.conf`
- `make list-stow` → Show stow packages in `stow.conf`
- `make add-stow PKG=package` → Add stow package to `stow.conf`
- `make remove-stow PKG=package` → Remove stow package from `stow.conf`

Example usage:

    make full-setup
    make backup
    make update
    make add-dir DIR=~/projects
    make add-stow PKG=tmux

---

## 🔑 Authentication

- The installer uses **GitHub CLI (`gh`)** to clone/pull this repo.  
- On the first run, it will ask you to `gh auth login`.  
- Use HTTPS + Browser login for the easiest flow.

---

## 💾 Capturing Current State of a Machine

To save the **current state** of your machine back into this repo:

1. Run:

       make backup

   This will:
   - Dump installed package lists (`apt`, `brew`, `snap`, `flatpak`, `pip`, `npm`, `cargo`)
   - Mirror tracked directories from `dirs.conf` into the repo
   - Auto-commit and push changes to git

The backup is automatic - no manual commit/push needed!

This way your repo always reflects the **latest working environment**.  

---

## 🧪 Testing

You can test this bootstrap process in a VM or container:  

    docker run -it ubuntu:24.04 bash
    # inside container
    apt update && apt install -y curl
    curl -fsSL https://raw.githubusercontent.com/blundercon/dotfiles/main/install.sh | bash

---

## 📝 Notes

- **Idempotent**: Running the installer or `make full-setup` multiple times is safe.  
- **Cross-platform**: Supports Linux (apt) + macOS (brew).  
- **Customizable**: Extend `bootstrap.sh` or add new configs under `stow/`.  

⚡ With this setup, a brand new laptop can go from **zero → full dev environment** in minutes.
