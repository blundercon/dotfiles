#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "🚀 Bootstrapping system from dotfiles..."

# macOS - Homebrew
if command -v brew &>/dev/null; then
  brew bundle --file=Brewfile || true
fi

# Ubuntu/Debian - APT
if command -v apt &>/dev/null; then
  xargs -a apt-packages.list sudo apt install -y || true
fi

# Snap
if command -v snap &>/dev/null; then
  cut -d' ' -f1 snap-packages.txt | tail -n +2 | xargs -n1 sudo snap install || true
fi

# Flatpak
if command -v flatpak &>/dev/null; then
  awk '{print $1}' flatpak-packages.txt | xargs -n1 flatpak install -y || true
fi

# Python
if command -v pip &>/dev/null; then
  pip install -r requirements.txt || true
fi

# Node
if command -v npm &>/dev/null; then
  awk '{print $2}' npm-global.txt | tail -n +2 | xargs -n1 npm install -g || true
fi

# Rust
if command -v cargo &>/dev/null; then
  awk '{print $1}' cargo-list.txt | xargs -n1 cargo install || true
fi

# Symlink configs using stow
if command -v stow &>/dev/null; then
  echo "🔗 Symlinking configs with stow..."
  cd stow && stow */
fi

echo "✅ Bootstrap complete!"
