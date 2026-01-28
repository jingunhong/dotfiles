#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d%H%M%S)"

info() { printf "\033[34m%s\033[0m\n" "$1"; }
success() { printf "\033[32m%s\033[0m\n" "$1"; }
warn() { printf "\033[33m%s\033[0m\n" "$1"; }

link_file() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        warn "Backing up $dest → ${dest}${BACKUP_SUFFIX}"
        mv "$dest" "${dest}${BACKUP_SUFFIX}"
    fi

    ln -s "$src" "$dest"
    success "Linked $dest → $src"
}

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install packages
info "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"

# Symlink configs
info "Linking dotfiles..."
link_file "$DOTFILES/zsh/.zshrc" ~/.zshrc
link_file "$DOTFILES/zsh/.zshenv" ~/.zshenv
link_file "$DOTFILES/nvim" ~/.config/nvim
link_file "$DOTFILES/wezterm/.wezterm.lua" ~/.wezterm.lua

# Sync Neovim plugins
info "Syncing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

success "Done!"
