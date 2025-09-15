#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting dotfiles bootstrap for blundercon..."

# --- Config ---
GITHUB_USER="blundercon"
DOTFILES_DIR="$HOME/dotfiles"

# --- Platform Detection ---
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        PLATFORM="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO="$ID"
        else
            DISTRO="unknown"
        fi
    else
        PLATFORM="unknown"
        DISTRO="unknown"
        echo "⚠️ Warning: Unknown platform $OSTYPE"
    fi

    echo "📋 Detected platform: $PLATFORM ($DISTRO)"
}

# --- Install package manager if needed ---
ensure_package_manager() {
    if [ "$PLATFORM" = "macos" ] && ! command -v brew &>/dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for this session
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    elif [ "$PLATFORM" = "linux" ] && command -v apt &>/dev/null; then
        sudo apt update
    fi
}

# --- Ensure prerequisites ---
install_pkg() {
    local pkg="$1"
    if ! command -v "$pkg" &>/dev/null; then
        echo "📦 Installing $pkg..."
        if [ "$PLATFORM" = "macos" ] && command -v brew &>/dev/null; then
            brew install "$pkg"
        elif command -v apt &>/dev/null; then
            sudo apt install -y "$pkg"
        else
            echo "❌ Please install $pkg manually."
            exit 1
        fi
    fi
}

# Initialize platform detection
detect_platform
ensure_package_manager

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

