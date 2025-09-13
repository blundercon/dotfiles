#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "🚀 Bootstrapping system from dotfiles..."

# --- macOS - Homebrew ---
if command -v brew &>/dev/null; then
  echo "📦 Installing packages via Homebrew..."
  brew bundle --file=Brewfile || true
  brew install htop glances ncdu || true
fi

# --- Ubuntu/Debian - APT ---
if command -v apt &>/dev/null; then
  echo "📦 Installing packages via apt..."
  sudo apt update -y
  xargs -a apt-packages.list sudo apt install -y || true
  sudo apt install -y htop glances ncdu || true
fi

# --- Snap ---
if command -v snap &>/dev/null; then
  echo "📦 Installing snap packages..."
  cut -d' ' -f1 snap-packages.txt | tail -n +2 | xargs -n1 sudo snap install || true
fi

# --- Flatpak ---
if command -v flatpak &>/dev/null; then
  echo "📦 Installing flatpak apps..."
  awk '{print $1}' flatpak-packages.txt | xargs -n1 flatpak install -y || true
fi

# --- Python ---
if command -v pip &>/dev/null; then
  echo "📦 Installing Python packages..."
  pip install -r requirements.txt || true
fi

# --- Node ---
if command -v npm &>/dev/null; then
  echo "📦 Installing global npm packages..."
  awk '{print $2}' npm-global.txt | tail -n +2 | xargs -n1 npm install -g || true
fi

# --- Rust ---
if command -v cargo &>/dev/null; then
  echo "📦 Installing Rust packages..."
  awk '{print $1}' cargo-list.txt | xargs -n1 cargo install || true
fi

# --- Symlink configs using stow ---
if command -v stow &>/dev/null; then
  echo "🔗 Symlinking configs with stow..."
  cd stow && stow --adopt */
fi

echo "✅ Bootstrap complete!"

