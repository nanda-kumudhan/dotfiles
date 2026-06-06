# Dotfiles

Personal Sway, Waybar, Rofi, GTK/Kvantum Gruvbox, Starship, Fastfetch, Foot, and shell config.

## Install

Run from a fresh Arch, Debian/Ubuntu, or Fedora-family system:

```bash
curl -fsSL https://raw.githubusercontent.com/nanda-kumudhan/dotfiles/main/bootstrap.sh | bash -s -- -y
```

On Arch, this reads `packages.txt`, shows what is already installed, asks before installing missing repo/AUR packages, and bootstraps `yay` if needed. On Debian/Ubuntu, it maps known Arch package names to APT package names and skips packages that are unavailable in the configured repositories, such as Android Studio, Arduino IDE, and AUR-only themes. If an APT batch install fails, the installer retries packages individually, reports any failures, and continues deploying the dotfiles. Missing visual assets are installed from their official upstream projects: JetBrainsMono Nerd Font under `~/.local/share/fonts`, Papirus with grey folders under `~/.local/share/icons`, and Gruvbox GTK under `~/.local/share/themes`. Omit `-y` for confirmation prompts:

```bash
curl -fsSL https://raw.githubusercontent.com/nanda-kumudhan/dotfiles/main/bootstrap.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/nanda-kumudhan/dotfiles.git ~/Github/dotfiles
cd ~/Github/dotfiles
./install.sh -y
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
./install.sh --no-themes
```

## Sync

Copy selected live dotfiles back into this repo:

```bash
./sync-from-home.sh
```

This also refreshes `packages.txt` from the current system. Arch uses `pacman -Qqe`; Debian/Ubuntu and Fedora use their native package tools.

Check first:

```bash
./sync-from-home.sh --check
```

The installer backs up replaced files under `~/.dotfiles-backup/`.
Only top-level hidden files and directories from the repository are deployed; package manifests, logs, and installer sources stay inside the clone.

The installer prints each command, its result and duration, stage summaries, and a final warning count. Optional package, font, theme, and service failures are reported and skipped. Failures that prevent cloning, backing up, or deploying dotfiles stop the installer with the stage, line, command, and log path.
