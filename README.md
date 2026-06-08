# Dotfiles

Personal Sway, Waybar, Rofi, GTK/Kvantum Gruvbox, Starship, Fastfetch, Foot, and shell config.

> [!IMPORTANT]
> These dotfiles support Arch Linux only. The installer requires `pacman` and may install packages from the AUR.

## Install

Run from a fresh Arch Linux system:

```bash
curl -fsSL https://raw.githubusercontent.com/nanda-kumudhan/dotfiles/main/bootstrap.sh | bash -s -- -y
```

The tracked `packages.txt` contains the complete package set. The installer uses only `pacman` and an AUR helper, shows what is already installed, asks before installing missing packages, and bootstraps `yay` if needed. Fonts, Papirus icons, Gruvbox GTK/icons, and the Kvantum theme are installed as Arch/AUR packages. After installation, `papirus-folders` applies grey folders to the Papirus themes. Omit `-y` for confirmation prompts:

```bash
curl -fsSL https://raw.githubusercontent.com/nanda-kumudhan/dotfiles/main/bootstrap.sh | bash
```

Useful options:

```bash
./install.sh --dry-run
./install.sh --copy
./install.sh --files-only
./install.sh --deps-only -y
./install.sh --enable-services -y
./install.sh --aur-helper paru
./install.sh --no-aur
```

The installer backs up replaced files under `~/.dotfiles-backup/`.
Only top-level hidden files and directories from the repository are deployed; package manifests, logs, and installer sources stay inside the clone.

The installer prints each command, its result and duration, stage summaries, and a final warning count. Package and service failures are reported and skipped. Failures that prevent cloning, backing up, or deploying dotfiles stop the installer with the stage, line, command, and log path.
