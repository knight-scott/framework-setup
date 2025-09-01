# Framework 13 Arch Linux Setup

This repository contains backup of my `.config` directory and a setup script to quickly configure a fresh Arch Linux install on my Framework 13 laptop running EndeavourOS with XFCE.

## What’s Inside

- `setup.sh` — a script to automate loading the backup, installing necessary tools, enabling BlackArch repo, and applying tweaks.

## Usage

1. Clone the repo on your fresh Arch install:
   ```
   git clone https://github.com/knight-scott/framework-setup.git
   cd framework-setup
   ```

2. Run the setup script:
   ```
   ./setup.sh
   ```

   The script will:
   - Restore your `.dotfiles`
   - Install essential tools if not found.
   - Enable BlackArch repo.
   - Apply other personal tweaks.S

## Updating Your Setup
 
!!! note
   TODO: fix .config reference

- After making config changes or tweaking your setup, create a new backup of `.config`:
  ```
  tar -czvf config-backup.tar.gz ~/.config
  ```
- Commit and push the new backup to GitHub.
- Update your `setup.sh` as needed for additional automation.

## Notes

- This setup assumes you are using EndeavourOS/Arch Linux with XFCE.
- Review the script before running to understand installed software and changes made.
- Use releases to manage versions of your backups and scripts for easy rollback.

---

*Maintained by 0x4B*
