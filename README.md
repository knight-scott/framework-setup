# Framework 13 Arch Linux Setup

Automated setup script to quickly configure a fresh Arch Linux install on my Framework 13 laptop running EndeavourOS with XFCE. This script bootstraps a complete development and security testing environment.

## What's Inside

- `setup.sh` — comprehensive setup script that handles dotfiles, packages, repos, and specialized tools
- Configuration for security research and penetration testing workflows
- Framework 13 specific optimizations and tweaks

## Usage

1. Clone the repo on your fresh Arch install:
   ```bash
   git clone https://github.com/knight-scott/framework-setup.git
   cd framework-setup
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

## What the Script Does

### Core Setup
- Installs essential system tools (`git`, `base-devel`, `wget`, `curl`, `stow`, `yay`)
- Clones and installs dotfiles from separate repository
- Updates system packages and synchronizes databases

### Security & Development Tools
- **Essential utilities**: `bat`, `fzf`, `htop`, `tree`, `vim`, `starship`
- **Network tools**: `nmap`, `gobuster`, `subfinder`, `wireshark`
- **Security testing**: `sqlmap`, `burpsuite`, `dirbuster`, `dirstalk`, `amass`
- **Applications**: `chromium`, `discord`, `obsidian`, `protonvpn-app`
- **Hardware tools**: `qFlipper`, `rpi-imager`
- **Containers**: `docker` with proper user group setup

### Specialized Components
- **BlackArch Repository**: Automatically installs and configures BlackArch repo for security tools
- **CyberChef**: Downloads and sets up offline version for data analysis
- **User Groups**: Adds user to `dialout` and `uucp` groups for hardware access

## System Requirements

- EndeavourOS/Arch Linux with XFCE
- Framework 13 hardware (optimized for this platform)
- Internet connection for package downloads
- Sudo privileges

## Notes

- Script is idempotent - safe to run multiple times
- Review the script before running to understand what software will be installed
- Some tools require manual configuration after installation
- Uses `yay` for AUR packages and `blackman` for BlackArch tools

## Planned Improvements

- [ ] Add support for additional package managers
- [ ] Implement ducktoolskit installation workaround  
- [ ] Create Obsidian field manual tool reference
- [ ] Add specialized tool installation scripts

---
*Maintained by 0x4B*