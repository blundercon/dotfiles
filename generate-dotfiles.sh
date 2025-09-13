#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

echo "📂 Creating dotfiles repo structure at $DOTFILES_DIR ..."
mkdir -p "$DOTFILES_DIR"

# --- Core structure ---
mkdir -p "$DOTFILES_DIR"/{stow/{bash,zsh,fish,git,vim,nvim,tmux,zellij,alacritty,vscode,misc},scripts,secrets}

# --- Base files ---
cat > "$DOTFILES_DIR/README.md" <<'EOF'
# Dotfiles Repo

This repo stores:
- Config files managed via GNU Stow
- Package lists (brew, apt, snap, flatpak, etc.)
- Backup + bootstrap scripts

## Usage
- `make backup` → update package lists and push
- `make bootstrap` → restore packages and symlink configs
EOF

# --- Makefile ---
cat > "$DOTFILES_DIR/Makefile" <<'EOF'
.PHONY: backup bootstrap stow clean

backup:
	./backup.sh

bootstrap:
	./bootstrap.sh

stow:
	cd stow && stow */

clean:
	cd stow && stow -D */
EOF

# --- Placeholder package lists ---
touch "$DOTFILES_DIR"/{Brewfile,apt-packages.list,snap-packages.txt,flatpak-packages.txt,requirements.txt,npm-global.txt,cargo-list.txt}

# --- Example configs ---
mkdir -p "$DOTFILES_DIR/stow/bash"
echo -e "# ~/.bashrc\nexport PATH=\"\$HOME/bin:\$PATH\"\nalias ll='ls -la'" > "$DOTFILES_DIR/stow/bash/.bashrc"

mkdir -p "$DOTFILES_DIR/stow/zsh"
echo -e "# ~/.zshrc\nexport ZSH=\"\$HOME/.oh-my-zsh\"\nZSH_THEME=\"robbyrussell\"\nplugins=(git)\nsource \$ZSH/oh-my-zsh.sh" > "$DOTFILES_DIR/stow/zsh/.zshrc"

mkdir -p "$DOTFILES_DIR/stow/fish/.config/fish"
echo -e "# ~/.config/fish/config.fish\nset -gx PATH \$HOME/bin \$PATH\nalias ll=\"ls -la\"" > "$DOTFILES_DIR/stow/fish/.config/fish/config.fish"

mkdir -p "$DOTFILES_DIR/stow/git"
echo -e "[user]\n    name = Your Name\n    email = your@email.com\n[core]\n    editor = nvim" > "$DOTFILES_DIR/stow/git/.gitconfig"

mkdir -p "$DOTFILES_DIR/stow/tmux"
echo -e "# ~/.tmux.conf\nset -g mouse on\nsetw -g mode-keys vi" > "$DOTFILES_DIR/stow/tmux/.tmux.conf"

mkdir -p "$DOTFILES_DIR/stow/zellij/.config/zellij"
echo -e "layout \"default\" {\n    pane size=1 borderless=true {\n        plugin location=\"zellij:tab-bar\"\n    }\n    pane {\n        plugin location=\"zellij:status-bar\"\n    }\n}" > "$DOTFILES_DIR/stow/zellij/.config/zellij/config.kdl"

mkdir -p "$DOTFILES_DIR/stow/vim"
echo -e "\" ~/.vimrc\nset number\nsyntax on" > "$DOTFILES_DIR/stow/vim/.vimrc"

mkdir -p "$DOTFILES_DIR/stow/nvim/.config/nvim"
echo -e "-- ~/.config/nvim/init.lua\nvim.o.number = true\nvim.o.relativenumber = true" > "$DOTFILES_DIR/stow/nvim/.config/nvim/init.lua"

mkdir -p "$DOTFILES_DIR/stow/alacritty/.config/alacritty"
echo -e "# ~/.config/alacritty/alacritty.yml\nfont:\n  normal:\n    family: monospace\n    style: Regular" > "$DOTFILES_DIR/stow/alacritty/.config/alacritty/alacritty.yml"

mkdir -p "$DOTFILES_DIR/stow/vscode/.config/Code/User"
echo -e "{\n  \"editor.fontSize\": 14,\n  \"editor.tabSize\": 2,\n  \"files.autoSave\": \"onFocusChange\"\n}" > "$DOTFILES_DIR/stow/vscode/.config/Code/User/settings.json"

# --- Backup Script ---
cat > "$DOTFILES_DIR/backup.sh" <<'EOF'
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
git push || echo "⚠️ Git push skipped (no remote?)"
EOF
chmod +x "$DOTFILES_DIR/backup.sh"

# --- Bootstrap Script ---
cat > "$DOTFILES_DIR/bootstrap.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "🚀 Bootstrapping system from dotfiles..."

# macOS - Homebrew
if command -v brew &>/dev/null; then
  brew bundle --file=Brewfile || true
fi

# Ubuntu/Debian - APT
if command -v apt &>/dev/null; then
  xargs -a apt-packages.list sudo apt install -y || true
fi

# Snap
if command -v snap &>/dev/null; then
  cut -d' ' -f1 snap-packages.txt | tail -n +2 | xargs -n1 sudo snap install || true
fi

# Flatpak
if command -v flatpak &>/dev/null; then
  awk '{print $1}' flatpak-packages.txt | xargs -n1 flatpak install -y || true
fi

# Python
if command -v pip &>/dev/null; then
  pip install -r requirements.txt || true
fi

# Node
if command -v npm &>/dev/null; then
  awk '{print $2}' npm-global.txt | tail -n +2 | xargs -n1 npm install -g || true
fi

# Rust
if command -v cargo &>/dev/null; then
  awk '{print $1}' cargo-list.txt | xargs -n1 cargo install || true
fi

# Symlink configs using stow
if command -v stow &>/dev/null; then
  echo "🔗 Symlinking configs with stow..."
  cd stow && stow */
fi

echo "✅ Bootstrap complete!"
EOF
chmod +x "$DOTFILES_DIR/bootstrap.sh"

echo "✨ Dotfiles repo skeleton (with Makefile) ready at: $DOTFILES_DIR"

