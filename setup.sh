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
DOTFILES_DIR="$HOME/.dotfiles"

# Clone dotfiles repo if missing
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles repo..."
    git clone "https://github.com/$REPO_USER/$DOTFILES_REPO.git" "$DOTFILES_DIR"
else
    # Update dotfiles if present
    echo "Updating dotfiles repo..."
    git -C "$DOTFILES_DIR" pull --rebase
fi

# === Run Dotfiles Installer ===
echo "Running dotfiles install script..."
bash "$HOME/.dotfiles/install.sh"

# Source shared function
source "$DOTFILES_DIR/lib.sh"
trap 'error_handler ${LINENO} $?' ERR

# == TODO ==
# Add check for package manager
# designed for Arch/pacman currently

# Ensure basic tools
sudo pacman -S --noconfirm --needed git base-devel wget curl stow yay

# === FUNCTIONS ===

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

# Installs missing BlackArch packages from a list using blackman
install_blackarch() {
    local pkgs=("$@")
    local missing=()
    
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing+=("$pkg")
        fi
    done
    
    if (( ${#missing[@]} )); then
        color_echo "$CYAN" "Installing missing BlackArch packages: ${missing[*]}"
        blackman -i "${missing[@]}"
    else
        color_echo "$GREEN" "All required BlackArch packages already installed."
    fi
}

add_user_to_group() {
    local group=$1
    if ! getent group "$group" > /dev/null; then
        color_echo "$YELLOW" "Group $group not found, creating..."
        sudo groupadd "$group"
    fi

    if id -nG "$USER" | grep -qw "$group"; then
        color_echo "$CYAN" "User $USER is already in group $group"
    else
        color_echo "$CYAN" "Adding user $USER to group $group"
        sudo usermod -aG "$group" "$USER"
    fi
}

# === TODO ===
# blackman install and use for install of haxx tools
# make list of hacking tools
# make reference list of tools using obsidian field manual

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

# Update group membership:
add_user_to_group dialout

# Install essential packages needed for setup and daily use
install_packages bat blackman chromium discord docker fzf htop lolcat nmap obsidian python python-pip qFlipper rpi-imager starship tree wireshark

# Blackman install list
install_blackarch burpsuite

# === TODO ===
# Blackman tools that do not work and have to be installed differently
# ducktoolskit

# Synchronize package lists and upgrade system
color_echo "$CYAN" "Synchronizing package databases and upgrading system packages..."
sudo pacman -Syyu --noconfirm
color_echo "$GREEN" "System packages synchronized and upgraded."
