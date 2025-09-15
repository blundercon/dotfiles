#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "💾 Starting backup..."

mkdir -p backups/dirs backups/stow backups/files

# --- Backup dirs from dirs.conf ---
if [ -f dirs.conf ]; then
  echo "📂 Backing up tracked dirs..."
  while read -r dir; do
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue
    expanded=$(eval echo "$dir")   # expand ~ to full path
    name=$(basename "$expanded")
    target="backups/dirs/$name"
    if [ -d "$expanded" ]; then
      mkdir -p "$target"
      rsync -a --delete "$expanded/" "$target/"
      echo "✅ Backed up $expanded → $target"
    else
      echo "⚠ Skipped $expanded (not found)"
    fi
  done < dirs.conf
fi

# --- Backup stow packages ---
if [ -f stow.conf ]; then
  echo "🔗 Backing up stow packages..."
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    if [ -d "stow/$pkg" ]; then
      mkdir -p "backups/stow/$pkg"
      rsync -a --delete "stow/$pkg/" "backups/stow/$pkg/"
      echo "✅ Backed up stow/$pkg → backups/stow/$pkg"
    else
      echo "⚠ Skipped stow/$pkg (not found)"
    fi
  done < stow.conf
fi

# --- Backup individual files ---
if [ -f files.conf ]; then
  echo "📄 Backing up specific files..."
  while read -r file; do
    [[ -z "$file" || "$file" =~ ^# ]] && continue
    expanded=$(eval echo "$file")
    name=$(basename "$expanded")
    target="backups/files/$name"
    if [ -f "$expanded" ]; then
      mkdir -p "$(dirname "$target")"
      cp "$expanded" "$target"
      echo "✅ Backed up $expanded → $target"
    else
      echo "⚠ Skipped $expanded (not found)"
    fi
  done < files.conf
fi

# --- Stage for git ---
if command -v git &>/dev/null; then
  git add backups/ || true
  echo "📦 Backup staged in git (run 'git commit' to save)"
fi

echo "🎉 Backup complete!"
