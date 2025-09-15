#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Platform detection and configuration
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
}

# Package manager detection
detect_package_managers() {
    AVAILABLE_MANAGERS=""

    if command -v brew &>/dev/null; then
        AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS brew"
    fi

    if command -v apt &>/dev/null; then
        AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS apt"
    fi

    if command -v dnf &>/dev/null; then
        AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS dnf"
    fi

    if command -v pacman &>/dev/null; then
        AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS pacman"
    fi

    if command -v snap &>/dev/null; then
        AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS snap"
    fi

    if command -v flatpak &>/dev/null; then
        AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS flatpak"
    fi
}

# Initialize platform detection
detect_platform
detect_package_managers

echo "🚀 Bootstrapping system from dotfiles..."
echo "📋 Platform: $PLATFORM ($DISTRO)"
echo "📦 Available package managers:$AVAILABLE_MANAGERS"

# Install packages from platform-specific and common package lists
install_packages() {
    # Install common packages first
    if [ -f packages/common.conf ]; then
        echo "📦 Installing common packages..."
        install_package_list packages/common.conf
    fi

    # Install platform-specific packages
    local platform_file=""
    case $DISTRO in
        macos)
            platform_file="packages/macos.conf"
            ;;
        ubuntu|debian)
            platform_file="packages/ubuntu.conf"
            ;;
        *)
            echo "⚠️ Unsupported platform $DISTRO. Only macOS and Ubuntu are supported."
            echo "📦 Using common packages only"
            ;;
    esac

    if [ -n "$platform_file" ] && [ -f "$platform_file" ]; then
        echo "📦 Installing $DISTRO-specific packages from $platform_file..."
        install_package_list "$platform_file"
    fi

    # Fallback: Install from legacy package files if they exist
    install_legacy_packages
}

install_package_list() {
    local package_file="$1"
    while read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        local pkg=$(echo "$line" | awk '{print $1}')  # Get first word as package name
        install_single_package "$pkg"
    done < "$package_file"
}

install_single_package() {
    local pkg="$1"
    echo "📦 Installing package: $pkg"

    if [[ "$AVAILABLE_MANAGERS" =~ brew ]] && [ "$DISTRO" = "macos" ]; then
        brew install "$pkg" || echo "⚠️ Failed to install $pkg via brew"
    elif [[ "$AVAILABLE_MANAGERS" =~ apt ]] && [[ "$DISTRO" =~ ^(ubuntu|debian) ]]; then
        sudo apt update -qq
        sudo apt install -y "$pkg" || echo "⚠️ Failed to install $pkg via apt"
    else
        echo "⚠️ Unsupported platform for package $pkg. Only macOS (brew) and Ubuntu (apt) are supported."
    fi
}

install_legacy_packages() {
    # Legacy Homebrew support
    if [[ "$AVAILABLE_MANAGERS" =~ brew ]] && [ -f Brewfile ]; then
        echo "📦 Installing legacy Homebrew packages from Brewfile..."
        brew bundle --file=Brewfile || echo "⚠️ Some Homebrew packages failed to install"
    fi

    # Legacy APT support
    if [[ "$AVAILABLE_MANAGERS" =~ apt ]] && [ -f apt-packages.list ]; then
        echo "📦 Installing legacy APT packages from apt-packages.list..."
        sudo apt update -qq
        xargs -a apt-packages.list sudo apt install -y || echo "⚠️ Some apt packages failed to install"
    fi
}

# Run package installation
install_packages

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

