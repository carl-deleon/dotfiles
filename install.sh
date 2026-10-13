#!/usr/bin/env bash
# Bootstrap a macOS machine from this dotfiles repo.
# Safe to re-run: existing files are backed up, existing installs are skipped.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# Symlink $1 (in repo) to $2, backing up any real file already at $2.
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    info "Backed up $dst -> $BACKUP/"
  fi
  ln -s "$src" "$dst"
  info "Linked $dst"
}

# 1. Xcode Command Line Tools (provides git)
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools — finish the popup, then re-run this script."
  xcode-select --install
  exit 0
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Packages from Brewfile
info "Installing Brewfile packages"
brew bundle --file="$DOTFILES/Brewfile" || info "Some Brewfile entries failed — check the output above."

# 4. Oh My Zsh + theme + plugins
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone() { [[ -d "$2" ]] || git clone --depth 1 "$1" "$2"; }
clone https://github.com/romkatv/powerlevel10k.git              "$ZSH_CUSTOM/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions.git      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 5. Symlink configs
link zsh/.zshrc               "$HOME/.zshrc"
link zsh/.zprofile            "$HOME/.zprofile"
link zsh/.p10k.zsh            "$HOME/.p10k.zsh"
link kitty/kitty.conf         "$HOME/.config/kitty/kitty.conf"
link kitty/current-theme.conf "$HOME/.config/kitty/current-theme.conf"

# 6. Machine-local secrets file (never committed)
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$DOTFILES/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  chmod 600 "$HOME/.zshrc.local"
  info "Created ~/.zshrc.local — fill in your tokens."
fi

info "Done. Open a new terminal (or run: exec zsh)."
