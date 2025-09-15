#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "💾 Starting backup..."

# --- Mirror working dirs from dirs.conf (structure only, contents ignored by .gitignore) ---
# Note: Tool directories (.gemini, .claude, .config/zellij) are now managed by stow packages
if [ -f dirs.conf ]; then
  echo "📂 Mirroring working directory structure..."
  while read -r dir; do
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue
    expanded="${dir/#\~/$HOME}"

    if [ ! -d "$expanded" ]; then
      echo "⚠️ Warning: Directory $expanded does not exist, skipping"
      continue
    fi

    relpath="${expanded/#$HOME\//}"
    mkdir -p "$relpath"
    rsync -a --delete "$expanded/" "$relpath/"
    echo "✅ Mirrored $expanded → $relpath"
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
    expanded="${file/#\~/$HOME}"

    if [ ! -f "$expanded" ]; then
      echo "⚠️ Warning: File $expanded does not exist, skipping"
      continue
    fi

    # Use portable relative path calculation (realpath --relative-to is GNU-specific)
    relpath="${expanded#$HOME/}"
    mkdir -p "$(dirname "$relpath")"
    cp "$expanded" "$relpath"
    echo "✅ Backed up $expanded → $relpath"
  done < files.conf
fi

# --- Stage, commit & push ---
if command -v git &>/dev/null; then
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git add -A
    git commit -m "chore(backup): update machine state on $(date +'%Y-%m-%d %H:%M:%S')" || true
    git push || echo "⚠️ Push failed, check your network/auth"
    echo "📦 Backup committed and pushed"
  else
    echo "✅ No changes to commit"
  fi
fi

echo "🎉 Backup complete!"
