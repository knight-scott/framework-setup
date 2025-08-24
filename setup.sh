#! /bin/bash

# install config from GitHub
wget -O config-backup.tar.gz https://github.com/knight-scott/framework-setup/releases/download/v1.0/config-backup.tar.gz
tar -xzvf config-backup.tar.gz -C ~/

# Check for apps and install any missing

# check for yay 
if ! command -v yay &> /dev/null; then
    # install if missing
    echo "${CYAN}Installing yay...${NC}\n"
    pacman -S yay

# check for Obsidian
if ! command -v obsidian &> /dev/null; then
    # install if missing
    echo "${CYAN}Installing Obsidian...${NC}\n"
    yay -S obsidian

# check for Chromium
if ! command -v chromium &> /dev/null; then
    # install if missing
    echo "${CYAN}Installing Chromium...${NC}\n"
    yay -S chromium

# check for Discord
if ! command -v discord &> /dev/null; then
    # install if missing
    echo "${CYAN}Installing Discord...${NC}\n"
    yay -S discord

# check for qFlipper
if ! command -v qFlipper &> /dev/null; then 
    # install if missing
    echo "${CYAN}Installing qFlipper...${NC}\n"
    yay -S qFlipper
fi

# Install BlackArch
echo "${CYAN}Downloading BlackArch install script...${NC}\n"
curl -O https://blackarch.org/strap.sh
sudo chmod +x strap.sh
echo "${CYAN}Running BlackArch install...${NC}\n"
sudo ./strap.sh
# clean up 
echo "${CYAN}Removing strap.sh...${NC}\n"
rm strap.sh

echo "${GREEN}BlackArch installed successfully.${NC}\n"

# Functions

# TODO: Make function for colored output

# check if directory exists
function checkdir() {
    if [ ! -d $1 ]; then
        echo "${CYAN}CREATING DIRECTORY: $1 ${NC}"
        mkdir -p $1
    fi
}

# Install Obsidian plugins
install_plugins() {
    echo "${CYAN}Installing plugins...{NC}\n"
    checkdir() $HOME/Documents/Obsidian\ Vault/.obsidian/plugins

    PLUGINS_FILE=plugins.json
    CORE_PLUGINS=$(jq -r '.core_plugins[]' $PLUGINS_FILE)
    COMMUNITY_PLUGINS=$(jq -r 'community_plugins[]' $PLUGINS_FILE)

    for plugin in $COMMUNITY_PLUGINS; do
        echo "${CYAN}Installing community plugin: $plugin{NC}\n"
        mkdir -p "$HOME/.obsidian/plugins/$plugin"
    done 

    echo "${GREEN}Plugins installed successfully.${NC}\n"
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

    echo "${CYAN}STARTING CYBERCHEF UPDATE${NC}\n"
    latest_chef_version=$(curl -sL https://api.github.com/repos/gchq/CyberChef/releases/latest | jq -r ".tag_name")
    latest_chef_url=$(curl -sL https://api.github.com/repos/gchq/CyberChef/releases/latest | jq -r ".assets[].browser_download_url")

    cd $HOME/Downloads
    echo "\n${CYAN}DOWNLOADING CYBERCHEF${NC}\n"
    wget "$latest_chef_url"

    echo "${CYAN}REMOVING OLD CYBERCHEF${NC}\n"
    rm -rf ~/Tools/CybercChef

    echo "\n${CYAN}UNZIPPING CYBERCHEF${NC}\n"
    unzip "CyberChef_$latest_chef_version.zip" -d ~/Tools/CyberChef
    mv "$HOME/Tools/CyberChef/CyberChef_$latest_chef_version.html" ~/Tools/CyberChef/index.html
        
    echo "\n${CYAN}CLEANING UP${NC}\n"
    rm CyberChef*
    cd $HOME

    echo "${GREEN}CYBERCHEF UPDATED${NC}\n"
    echo "${GREEN}ACCESS CYBERCHEF VIA: 'chef'${NC}\n"
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
