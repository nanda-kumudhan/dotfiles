# Dotfiles

Black monochrome Sway desktop configuration.

## Included

- Sway config and scripts
- Waybar config, style, and Pomodoro script
- Rofi launcher/menu scripts and theme
- Kanshi output profiles
- Mako notifications
- Foot terminal
- Starship prompt
- Fastfetch
- Bash startup files
- GTK/Qt theme hints
- Wallpapers referenced by Sway

## Excluded

Generated state, caches, app databases, crash dumps, LocalSend keys, and Rofi application cache data are intentionally not tracked.

## Install

From this repo:

```sh
./install.sh
```

The installer symlinks tracked files into `$HOME`. Existing files are backed up under `~/.dotfiles-backup/<timestamp>/`.

