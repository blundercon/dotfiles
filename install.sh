#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting dotfiles bootstrap for blundercon..."

# --- Config ---
GITHUB_USER="blundercon"
DOTFILES_DIR="$HOME/dotfiles"

# --- Ensure prerequisites ---
install_pkg() {
  local pkg="$1"
  if ! command -v "$pkg" &>/dev/null; then
    echo "📦 Installing $pkg..."
    if command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y "$pkg"
    elif command -v brew &>/dev/null; then
      brew install "$pkg"
    else
      echo "❌ Please install $pkg manually."
      exit 1
    fi
  fi
}

install_pkg git
install_pkg gh
install_pkg make
install_pkg stow

# --- Authenticate GitHub ---
if ! gh auth status &>/dev/null; then
  echo "🔑 Logging into GitHub..."
  gh auth login
else
  echo "ℹ️ GitHub CLI already authenticated."
fi

# --- Clone or pull latest dotfiles repo ---
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "📥 Cloning dotfiles repo for $GITHUB_USER..."
  gh repo clone "$GITHUB_USER/dotfiles" "$DOTFILES_DIR" || {
    echo "⚠️ Repo not found, creating a new one..."
    gh repo create "$GITHUB_USER/dotfiles" --private --clone
  }
else
  echo "🔄 Updating existing dotfiles repo..."
  git -C "$DOTFILES_DIR" pull --rebase --autostash
fi

# --- Run full setup via Makefile ---
if [ -f "$DOTFILES_DIR/Makefile" ]; then
  echo "⚡ Running full setup (dirs + bootstrap + backup)..."
  make -C "$DOTFILES_DIR" full-setup
else
  echo "⚠️ No Makefile found in $DOTFILES_DIR. Please add one."
  exit 1
fi

echo "✅ Dotfiles + environment bootstrap complete for $GITHUB_USER!"

