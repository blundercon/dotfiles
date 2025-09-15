#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "💾 Starting backup..."

# --- Backup dirs from dirs.conf ---
if [ -f dirs.conf ]; then
  echo "📂 Backing up tracked dirs..."
  while read -r dir; do
    # skip empty lines & comments
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue
    name=$(basename "$dir")
    target="backups/dirs/$name"
    mkdir -p "$(dirname "$target")"
    if [ -d "$dir" ]; then
      rsync -a --delete "$dir/" "$target/"
      echo "✅ Backed up $dir → $target"
    else
      echo "⚠️ Skipped $dir (not found)"
    fi
  done < dirs.conf
fi

# --- Backup stow packages from stow.conf ---
if [ -f stow.conf ]; then
  echo "🔗 Backing up stow packages..."
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    if [ -d "stow/$pkg" ]; then
      rsync -a --delete "stow/$pkg/" "backups/stow/$pkg/"
      echo "✅ Backed up stow/$pkg → backups/stow/$pkg"
    else
      echo "⚠️ Skipped stow/$pkg (not found)"
    fi
  done < stow.conf
fi

# --- Stage changes for git ---
if command -v git &>/dev/null; then
  git add backups/ || true
  echo "📦 Backup staged in git (run 'git commit' to save)"
fi

echo "🎉 Backup complete!"
