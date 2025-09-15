#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "🚀 Bootstrapping system from dotfiles..."

# --- macOS - Homebrew ---
if command -v brew &>/dev/null; then
  echo "📦 Installing packages via Homebrew..."
  if [ -f Brewfile ]; then
    brew bundle --file=Brewfile || echo "⚠️ Some Homebrew packages failed to install"
  else
    echo "⚠️ No Brewfile found, skipping brew bundle"
  fi
  brew install htop glances ncdu || echo "⚠️ Failed to install some basic packages"
fi

# --- Ubuntu/Debian - APT ---
if command -v apt &>/dev/null; then
  echo "📦 Installing packages via apt..."
  sudo apt update -y
  if [ -f apt-packages.list ]; then
    xargs -a apt-packages.list sudo apt install -y || echo "⚠️ Some apt packages failed to install"
  else
    echo "⚠️ No apt-packages.list found, skipping apt packages"
  fi
  sudo apt install -y htop glances ncdu || echo "⚠️ Failed to install some basic packages"
fi

# --- Snap ---
if command -v snap &>/dev/null && [ -f snap-packages.txt ]; then
  echo "📦 Installing snap packages..."
  cut -d' ' -f1 snap-packages.txt | tail -n +2 | xargs -n1 sudo snap install || echo "⚠️ Some snap packages failed to install"
fi

# --- Flatpak ---
if command -v flatpak &>/dev/null && [ -f flatpak-packages.txt ]; then
  echo "📦 Installing flatpak apps..."
  awk '{print $1}' flatpak-packages.txt | xargs -n1 flatpak install -y || echo "⚠️ Some flatpak packages failed to install"
fi

# --- Python ---
if command -v pip &>/dev/null && [ -f requirements.txt ]; then
  echo "📦 Installing Python packages..."
  pip install -r requirements.txt || echo "⚠️ Some Python packages failed to install"
fi

# --- Node ---
if command -v npm &>/dev/null && [ -f npm-global.txt ]; then
  echo "📦 Installing global npm packages..."
  awk '{print $2}' npm-global.txt | tail -n +2 | xargs -n1 npm install -g || echo "⚠️ Some npm packages failed to install"
fi

# --- Rust ---
if command -v cargo &>/dev/null && [ -f cargo-list.txt ]; then
  echo "📦 Installing Rust packages..."
  awk '{print $1}' cargo-list.txt | xargs -n1 cargo install || echo "⚠️ Some Rust packages failed to install"
fi

# --- Symlink configs using stow ---
if command -v stow &>/dev/null; then
  echo "🔗 Symlinking configs with stow..."
  if [ ! -d stow ]; then
    echo "❌ Error: stow directory not found"
    exit 1
  fi
  cd stow
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    if [ -d "$pkg" ]; then
      echo "🔗 Stowing $pkg..."
      stow --adopt "$pkg" || echo "⚠️ Failed to stow $pkg"
    else
      echo "⚠️ Warning: stow package $pkg not found, skipping"
    fi
  done < ../stow.conf
else
  echo "⚠️ stow not installed, skipping dotfile symlinks"
fi

echo "✅ Bootstrap complete!"

