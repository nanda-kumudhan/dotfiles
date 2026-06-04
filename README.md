# Dotfiles

Personal Sway, Waybar, Rofi, GTK/Kvantum Gruvbox, Starship, Fastfetch, Foot, and shell config.

## Install

Run from a fresh Arch, Debian/Ubuntu, or Fedora-family system:

```bash
curl -fsSL https://raw.githubusercontent.com/nanda-kumudhan/dotfiles/main/bootstrap.sh | bash -s -- -y
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
```

## Sync

Copy selected live dotfiles back into this repo:

```bash
./sync-from-home.sh
```

Check first:

```bash
./sync-from-home.sh --check
```

The installer backs up replaced files under `~/.dotfiles-backup/`.
