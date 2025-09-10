#!/bin/bash
# `setup.sh` — comprehensive setup script that handles dotfiles, packages, repos, and specialized tools
# Configuration for security research and penetration testing workflows
# Framework 13 specific optimizations and tweaks

set -euo pipefail

# Configuration variables
REPO_USER="knight-scott"    # GitHub username
DOTFILES_REPO="dotfiles"    # Repo containing install.sh + lib.sh
SETUP_REPO="framework-setup" # Repo name containing backups & scripts
RELEASE_TAG="v1.0"          # Release tag version
DOTFILES_DIR="$HOME/.dotfiles"

# Ensure basic tools
sudo pacman -S --noconfirm --needed git base-devel wget curl stow yay

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

# Cyber Chef install
install_cyberchef() {
    local tools_dir="$HOME/Tools"
    local chef_dir="$tools_dir/cyberchef"
    
    color_echo "$CYAN" "Installing CyberChef..."
    
    # Create directories
    checkdir "$tools_dir"
    checkdir "$chef_dir"
    
    # Get latest version info
    local latest_version=$(curl -sL https://api.github.com/repos/gchq/CyberChef/releases/latest | jq -r ".tag_name")
    local download_url=$(curl -sL https://api.github.com/repos/gchq/CyberChef/releases/latest | jq -r ".assets[].browser_download_url")
    
    # Check if already installed
    if [[ -f "$chef_dir/index.html" ]]; then
        color_echo "$YELLOW" "CyberChef already installed, skipping..."
        return
    fi
    
    color_echo "$CYAN" "Downloading CyberChef $latest_version..."
    cd "$HOME/Downloads"
    wget -q "$download_url"
    
    color_echo "$CYAN" "Extracting CyberChef..."
    rm -rf "$chef_dir"
    unzip -q "CyberChef_$latest_version.zip" -d "$chef_dir"
    mv "$chef_dir/CyberChef_$latest_version.html" "$chef_dir/index.html"
    
    # Cleanup
    rm -f "CyberChef_$latest_version.zip"
    cd "$HOME"
    
    color_echo "$GREEN" "CyberChef installed to $chef_dir"
}

# DuckToolkit install
install_ducktoolkit() {
    local tools_dir="$HOME/Tools"
    local duck_dir="$tools_dir/DuckToolkit"
    
    color_echo "$CYAN" "Installing DuckToolkit..."
    
    # Create tools directory
    checkdir "$tools_dir"
    
    # Check if already installed
    if [[ -d "$duck_dir" ]]; then
        color_echo "$YELLOW" "DuckToolkit already installed, skipping..."
        return
    fi
    
    # Clone the repository using git
    color_echo "$CYAN" "Cloning DuckToolkit repository..."
    cd "$tools_dir"
    
    if git clone https://github.com/kevthehermit/DuckToolkit.git; then
        color_echo "$GREEN" "DuckToolkit installed to $duck_dir"

        # Install DuckToolkit
        color_echo "$CYAN" "Installing DuckToolkit dependencies..."
        cd "$duck_dir"
        sudo python setup.py install
        
        color_echo "$GREEN" "DuckToolkit installation complete!"
    else
        color_echo "$RED" "Failed to clone DuckToolkit repository"
        return 1
    fi

    cd "$HOME"
}

# Install AWS CLI v2
install_awscli() {
    color_echo "$CYAN" "Installing AWS CLI v2..."
    
    # Check if AWS CLI is already installed
    if command -v aws &> /dev/null; then
        local current_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
        color_echo "$YELLOW" "AWS CLI already installed (version: $current_version), skipping..."
        return
    fi
    
    color_echo "$CYAN" "Downloading AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    
    color_echo "$CYAN" "Extracting AWS CLI..."
    unzip awscliv2.zip
    
    color_echo "$CYAN" "Installing AWS CLI..."
    sudo ./aws/install
    
    # Cleanup
    rm -f awscliv2.zip
    rm -rf aws/
    
    # Verify installation
    if command -v aws &> /dev/null; then
        local installed_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
        color_echo "$GREEN" "AWS CLI v$installed_version installed successfully"
    else
        color_echo "$RED" "AWS CLI installation failed"
        return 1
    fi
}

# Configure LightDM Slick Greeter with custom backgrounds
configure_lightdm() {
    local backgrounds_dir="/usr/share/pixmaps/backgrounds"
    local greeter_conf="/etc/lightdm/slick-greeter.conf"
    
    color_echo "$CYAN" "Configuring LightDM Slick Greeter..."
    
    # Create backgrounds directory if it doesn't exist
    sudo mkdir -p "$backgrounds_dir"
    
    # Copy custom background images from dotfiles
    if [[ -d "$DOTFILES_DIR/backgrounds" ]]; then
        color_echo "$CYAN" "Copying custom background images..."
        sudo cp -r "$DOTFILES_DIR/backgrounds/"* "$backgrounds_dir/"
        sudo chmod 644 "$backgrounds_dir"/*
        color_echo "$GREEN" "Background images copied to $backgrounds_dir"
    else
        color_echo "$YELLOW" "No backgrounds directory found in dotfiles, skipping image copy..."
    fi
    
    # Backup existing greeter config
    backup_if_exists "$greeter_conf"
    
    # Copy custom greeter configuration
    if [[ -f "$DOTFILES_DIR/lightdm/slick-greeter.conf" ]]; then
        color_echo "$CYAN" "Installing custom slick-greeter configuration..."
        sudo cp "$DOTFILES_DIR/lightdm/slick-greeter.conf" "$greeter_conf"
        color_echo "$GREEN" "Slick greeter configuration installed"
    else
        # Create a basic configuration if no custom config exists
        color_echo "$CYAN" "Creating default slick-greeter configuration..."
        sudo tee "$greeter_conf" > /dev/null << EOF
[Greeter]
# Background image
background=$backgrounds_dir/desktop-wallpaper.png
# Optional: Enable user background selection
draw-user-backgrounds=false
draw-grid=true
# Theme settings
theme-name=Arc-dark
icon-theme-name=Qogir
cursor-theme-name=Qogir
cursor-theme-size=16
# Other Settings
show-a11y=false
show-power=false
background-color=#000000
show-clock=true
clock-format=%H:%M
EOF
        color_echo "$GREEN" "Default slick greeter configuration created"
    fi
    
    # Set proper permissions
    sudo chown root:root "$greeter_conf"
    sudo chmod 644 "$greeter_conf"
    
    color_echo "$GREEN" "LightDM Slick Greeter configuration complete!"
    color_echo "$YELLOW" "Note: Changes will take effect on next logout/reboot"
}



# === TODO ===
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
# use dialout if not in Arch
add_user_to_group uucp

# Configure LightDM Slick Greeter with custom backgrounds
configure_lightdm

# Install essential packages needed for setup and daily use
install_packages android-sdk bat bitwarden blackman chromium discord docker fzf github-cli gobuster htop lightdm lightdm-slick-greeter lolcat nmap obsidian protonvpn-app python python-pip qFlipper rpi-imager sqlmap starship subfinder tree vim wireshark

# Blackman install list
install_blackarch airoscript amass android-sdk-platform-tools burpsuite cewl cloud-enum dirbuster dirstalk enum4linux ffuf seclists sliver 

# Install CyberChef
install_cyberchef

# Install DuckToolkit
install_ducktoolkit

# Install AWS CLI v.2
install_awscli

# === TODO ===
# Blackman tools that do not work and have to be installed differently
# special tool install script in .dotfiles > scripts and call here

# Synchronize package lists and upgrade system
color_echo "$CYAN" "Synchronizing package databases and upgrading system packages..."
sudo pacman -Syyu --noconfirm
color_echo "$GREEN" "System packages synchronized and upgraded."