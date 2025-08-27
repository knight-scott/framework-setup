#!/bin/bash
# setup.sh - Bootstraps system setup on a fresh Arch-based install.
# Downloads and restores config backup, pulls dotfiles repo,
# installs essential packages, installs BlackArch repo if missing,
# and synchronizes and upgrades all packages.

set -euo pipefail

# Configuration variables
REPO_USER="knight-scott"    # GitHub username
DOTFILES_REPO="dotfiles"    # Repo containing install.sh + lib.sh
SETUP_REPO="framework-setup" # Repo name containing backups & scripts
RELEASE_TAG="v1.0"          # Release tag version
CONFIG_ARCHIVE="config-backup.tar.gz"  # Backup file name
DOTFILES_DIR="$HOME/.dotfiles"

# Source shared function
source "$(dirname "$0")/lib.sh"
trap 'error_handler ${LINENO} $?' ERR

# Clone dotfiles repo if missing
if [[ ! -d "$DOTFILES_DIR" ]]; then
    color_echo "$CYAN" "Cloning dotfiles repo..."
    git clone "https://github.com/$REPO_USER/$DOTFILES_REPO.git" "$DOTFILES_DIR"
else
    color_echo "$CYAN" "Updating dotfiles repo..."
    git -C "$DOTFILES_DIR" pull --rebase
fi

# === Config Backup Restore ===
color_echo "$CYAN" "Downloading config backup from GitHub Releases..."
wget -q --show-progress -O "$CONFIG_ARCHIVE" "https://github.com/$REPO_USER/$SETUP_REPO/releases/download/$RELEASE_TAG/$CONFIG_ARCHIVE"

color_echo "$CYAN" "Extracting config backup to home directory..."
tar -xzf "$CONFIG_ARCHIVE" -C "$HOME"
rm -f "$CONFIG_ARCHIVE"

# Clone or update the dotfiles repo
if [[ -d "$HOME/.dotfiles" ]]; then
    color_echo "$CYAN" "Dotfiles repo found, updating..."
    git -C "$HOME/.dotfiles" pull --rebase
else
    color_echo "$CYAN" "Cloning dotfiles repo for the first time..."
    git clone "git@github.com:$REPO_USER/dotfiles.git" "$HOME/.dotfiles"
fi

# === Run Dotfiles Installer ===
color_echo "$CYAN" "Running dotfiles install script..."
bash "$HOME/.dotfiles/install.sh"

# === Package Installation Helper ===
# Installs missing packages from a list using yay.
install_packages() {
    local pkgs=("$@")
    local missing=()

    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing+=("$pkg")
        fi
    done

    if (( ${#missing[@]} )); then
        color_echo "$CYAN" "Installing missing packages: ${missing[*]}"
        yay -S --noconfirm "${missing[@]}"
    else
        color_echo "$GREEN" "All required packages already installed."
    fi
}

# Install essential packages needed for setup and daily use
install_packages bat chromium discord docker fzf htop lolcat obsidian qFlipper rpi-imager starship stow tree yay

# === BlackArch Repo ===
# BlackArch repo installation if not already present
if ! grep -q "^blackarch" /etc/pacman.conf 2>/dev/null; then
    color_echo "$CYAN" "Installing BlackArch repository..."
    curl -O https://blackarch.org/strap.sh
    sudo chmod +x strap.sh
    sudo ./strap.sh
    rm -f strap.sh
    color_echo "$GREEN" "BlackArch repo installed successfully."
else
    color_echo "$YELLOW" "BlackArch repo already installed; skipping."
fi

# Synchronize package lists and upgrade system
color_echo "$CYAN" "Synchronizing package databases and upgrading system packages..."
sudo pacman -Syyu --noconfirm
color_echo "$GREEN" "System packages synchronized and upgraded."
