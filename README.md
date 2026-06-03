# Dotfiles

Personal Sway/Waybar/Foot/Rofi/Fastfetch/Starship setup for Arch or Debian-family systems.

This repo can:

- Install the packages this setup expects.
- Put the dotfiles in the right places under `$HOME`.
- Back up anything it replaces.
- Keep a log of what happened.
- Sync live config changes back into the repo.

It does not commit or push anything for you.

## Quick Install

Clone the repo, then run:

```bash
cd ~/Github/dotfiles
./install.sh --dry-run
```

If the dry run looks sane, install packages and link the dotfiles:

```bash
./install.sh -y
```

To enable NetworkManager and Bluetooth services too:

```bash
./install.sh -y --enable-services
```

## What Gets Installed

The installer detects Arch vs Debian/Ubuntu-family systems from `/etc/os-release`.

It installs the tools used by this setup, including:

- Sway, swayidle, swaylock
- Waybar, Mako, Rofi, Foot
- Fastfetch, Starship, htop
- PipeWire, WirePlumber, pavucontrol
- NetworkManager, Bluetooth tools
- grim, slurp, wl-clipboard, cliphist
- Thunar, KeePassXC, wdisplays, mpv
- JetBrains Mono Nerd Font, Font Awesome, Noto emoji, Papirus icons

Some package names differ between Arch and Debian. The installer filters unavailable package names and prints warnings instead of blindly failing on the first missing optional package.

## Dotfile Install Modes

Default mode is symlink:

```bash
./install.sh
```

That links files from this repo into `$HOME`, so editing either side edits the same file.

Copy mode creates real files instead:

```bash
./install.sh --copy
```

Use copy mode if you do not want your live config files tied directly to the repo.

## Backups

Before replacing an existing file, the installer moves it into:

```text
~/.dotfiles-backup/YYYYMMDD-HHMMSS/
```

The installer also writes a log by default:

```text
~/.dotfiles-backup/install-YYYYMMDD-HHMMSS.log
```

Use a custom log path:

```bash
./install.sh --log-file /tmp/dotfiles-install.log
```

Use a custom backup root:

```bash
DOTFILES_BACKUP_ROOT=~/dotfiles-backups ./install.sh
```

## Common Commands

Install dependencies only:

```bash
./install.sh --deps-only -y
```

Deploy files only:

```bash
./install.sh --files-only
```

Deploy files only, as copies:

```bash
./install.sh --files-only --copy
```

Skip font fallback install:

```bash
./install.sh --no-fonts
```

Show help:

```bash
./install.sh --help
```

## Sync Changes Back

If you change live config files and want to copy them back into the repo:

```bash
./sync-from-home.sh
```

Check what would differ without copying:

```bash
./sync-from-home.sh --check
```

Dry run:

```bash
./sync-from-home.sh --dry-run
```

List the files it manages:

```bash
./sync-from-home.sh --list
```

The sync script uses an allowlist. It does not copy the whole `.config` directory, because that would pull in caches, databases, logs, trash, browser/app state, and other junk.

## What Is In Here

Main pieces:

```text
.bashrc
.bash_profile
.profile
.xprofile
.gitconfig
.gtkrc-2.0
.vimrc
.emacs
.config/sway/
.config/waybar/
.config/rofi/
.config/foot/
.config/fastfetch/
.config/starship.toml
.config/mako/
.config/htop/
.config/nvim/
.vim/
```

Useful scripts:

```text
install.sh          repo -> home
sync-from-home.sh   home -> repo
```

Waybar includes a Pomodoro timer script at:

```text
.config/waybar/scripts/pomodoro
```

## After Install

Log out and back in after a full install, especially if this is a fresh Sway setup.

If already inside Sway, reload with:

```bash
swaymsg reload
```

Start a new terminal to pick up Foot, Bash, Starship, and Fastfetch changes.

## Notes

- The Sway config contains output names like `eDP-1` and `HDMI-1`. Change them if your machine uses different output names.
- Some files contain absolute paths under `/home/nanda-kumudhan`. The installer warns if `$HOME` is different.
- The repo is intentionally not automatic about `git commit` or `git push`. Review changes yourself with:

```bash
git status
git diff
```
