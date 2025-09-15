#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "💾 Starting backup..."

# --- Ensure dirs from dirs.conf are mirrored in repo ---
if [ -f dirs.conf ]; then
  echo "📂 Mirroring tracked dirs in repo..."
  while read -r dir; do
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue
    expanded=$(eval echo "$dir")
    relpath=$(realpath --relative-to="$HOME" "$expanded")

    mkdir -p "$relpath"

    # Drop a .gitkeep if directory is empty
    if [ -z "$(ls -A "$relpath" 2>/dev/null)" ]; then
      touch "$relpath/.gitkeep"
    fi

    echo "✅ Ensured $relpath (mirrored from $expanded)"
  done < dirs.conf
fi

# --- Backup package lists ---
if command -v apt &>/dev/null; then
  apt list --installed > apt-packages.list || true
fi

if command -v brew &>/dev/null; then
  brew bundle dump --file=Brewfile --force || true
fi

if command -v snap &>/dev/null; then
  snap list > snap-packages.txt || true
fi

if command -v flatpak &>/dev/null; then
  flatpak list --app > flatpak-packages.txt || true
fi

if command -v pip &>/dev/null; then
  pip freeze > requirements.txt || true
fi

if command -v npm &>/dev/null; then
  npm list -g --depth=0 > npm-global.txt || true
fi

if command -v cargo &>/dev/null; then
  cargo install --list | awk '{print $1}' > cargo-list.txt || true
fi

# --- Backup explicit files from files.conf ---
if [ -f files.conf ]; then
  echo "📄 Backing up specific files..."
  while read -r file; do
    [[ -z "$file" || "$file" =~ ^# ]] && continue
    expanded=$(eval echo "$file")
    relpath=$(realpath --relative-to="$HOME" "$expanded")
    mkdir -p "$(dirname "$relpath")"
    cp "$expanded" "$relpath"
    echo "✅ Backed up $expanded → $relpath"
  done < files.conf
fi

# --- Stage for git ---
if command -v git &>/dev/null; then
  git add . || true
  echo "📦 Backup staged in git (run 'git commit' to save)"
fi

echo "🎉 Backup complete!"
