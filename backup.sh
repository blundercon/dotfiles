#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "🔄 Updating package lists..."

if command -v brew &>/dev/null; then
  brew bundle dump --file=Brewfile --force
fi

if command -v apt &>/dev/null; then
  apt-mark showmanual > apt-packages.list
fi

if command -v snap &>/dev/null; then
  snap list > snap-packages.txt
fi

if command -v flatpak &>/dev/null; then
  flatpak list --app > flatpak-packages.txt
fi

if command -v pip &>/dev/null; then
  pip freeze > requirements.txt
fi

if command -v npm &>/dev/null; then
  npm list -g --depth=0 > npm-global.txt
fi

if command -v cargo &>/dev/null; then
  cargo install --list > cargo-list.txt
fi

git add .
git commit -m "Update package/app lists" || echo "ℹ️ No changes to commit"
git push
