#! /bin/bash
# setup.sh - System bootstrapper

set -euo pipefail

# Import shared functions
source "$(dirname "$0")/lib.sh"

# install config from GitHub
wget -O config-backup.tar.gz https://github.com/knight-scott/framework-setup/releases/download/v1.0/config-backup.tar.gz
tar -xzvf config-backup.tar.gz -C ~/

# pull dotfiles
if [[ ! -d "$HOME/.dotfiles" ]]; then
  git clone git@github.com:knight-scott/dotfiles.git "$HOME/.dotfiles"
fi

"$HOME/.dotfiles/install.sh"

# Check for apps and install any missing

# check for yay 
if ! command -v yay &> /dev/null; then
    # install if missing
    echo "$CYAN""Installing yay...\n"
    pacman -S yay
fi

# check for Obsidian
if ! command -v obsidian &> /dev/null; then
    # install if missing
    echo "$CYAN""Installing Obsidian...\n"
    yay -S obsidian
fi

# check for Chromium
if ! command -v chromium &> /dev/null; then
    # install if missing
    echo "$CYAN""Installing Chromium...\n"
    yay -S chromium
fi 

# check for Discord
if ! command -v discord &> /dev/null; then
    # install if missing
    echo "$CYAN""Installing Discord...\n"
    yay -S discord
fi

# check for qFlipper
if ! command -v qFlipper &> /dev/null; then 
    # install if missing
    echo "$CYAN""Installing qFlipper...\n"
    yay -S qFlipper
fi

# Call dotfiles installer
~/.dotfiles/install.sh

# Install BlackArch
echo "$CYAN""Downloading BlackArch install script...\n"
curl -O https://blackarch.org/strap.sh
sudo chmod +x strap.sh
echo "$CYAN""Running BlackArch install...\n"
sudo ./strap.sh
# clean up 
echo "$CYAN""Removing strap.sh...\n"
rm strap.sh

echo "$GREEN""BlackArch installed successfully.\n"

# Install Obsidian plugins
install_plugins() {
    color_echo "$CYAN" "Installing plugins...\n"
    checkdir "$HOME/Documents/Obsidian Vault/.obsidian/plugins"

    PLUGINS_FILE=$HOME/.dotfiles/obsidian/community-plugins.json
    CORE_PLUGINS=$(jq -r '.core_plugins[]' $PLUGINS_FILE)
    COMMUNITY_PLUGINS=$(jq -r '.community_plugins[]' $PLUGINS_FILE)

    for plugin in $COMMUNITY_PLUGINS; do
        color_echo "$CYAN""Installing community plugin: $plugin\n"
        mkdir -p "$HOME/.obsidian/plugins/$plugin"
    done

    LIVE_DIR="$HOME/Documents/Obsidian Vault/.obsidian/plugins/obsidian-livesync"
    checkdir "$LIVE_DIR"

    if [ ! -f "$LIVE_DIR/data.json" ]; then
        cp "$HOME/.dotfiles/obsidian/default-livesync-data.json" "$LIVE_DIR/data.json"
        color_echo "$CYAN""Applied default LiveSync config.\n"
    else
        color_echo "$YELLOW""LiveSync data.json already exists, skipping.\n"
    fi

    color_echo "$GREEN""Plugins installed successfully.\n"
}

# Install BlackArch tools
# TODO: list and install primary tools
# Check against Parrot, Kali, and pwn.labs tools

# Install CyberChef
function chef() {
    chefUrl='file:///home/$USER/Tools/CyberChef/index.html'
    if xdg-settings get default-web-browser | grep firefox; then firefox $chefUrl; else xdg-open $chefUrl; fi
}

function chefupdate() {
    checkdir $HOME/Tools/
    checkdir $HOME/Tools/CyberChef

    color_echo "$CYAN""STARTING CYBERCHEF UPDATE\n"
    latest_chef_version=$(curl -sL https://api.github.com/repos/gchq/CyberChef/releases/latest | jq -r ".tag_name")
    latest_chef_url=$(curl -sL https://api.github.com/repos/gchq/CyberChef/releases/latest | jq -r ".assets[].browser_download_url")

    cd $HOME/Downloads
    color_echo "$CYAN""DOWNLOADING CYBERCHEF\n"
    wget "$latest_chef_url"

    color_echo "$CYAN""REMOVING OLD CYBERCHEF\n"
    rm -rf ~/Tools/CybercChef

    color_echo "$CYAN""UNZIPPING CYBERCHEF\n"
    unzip "CyberChef_$latest_chef_version.zip" -d ~/Tools/CyberChef
    mv "$HOME/Tools/CyberChef/CyberChef_$latest_chef_version.html" ~/Tools/CyberChef/index.html
        
    color_echo "CYAN""CLEANING UP\n"
    rm CyberChef*
    cd $HOME

    color_echo "$GREEN""CYBERCHEF UPDATED\n"
    echo "$GREEN""ACCESS CYBERCHEF VIA: 'chef'\n"
}

# Install Hardware Tools
# None yet
# check for and make directories
# qFlipper - installed with 
# raspberry pi flasher
# install Proton VPN
# install wireguard-tools
# sudo systemctl enable --now systemd-resolved.service
# wg-quick up /etc/wireguard/framework-vpn.conf

# TODO: Future proofing:
# 1. handle machine-specific configs
# 1a. handle distro specific configs
# 2. backup existing files before symlinking
# 3. Auto-pull latest dotfiles repo before applying
