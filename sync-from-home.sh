#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
timestamp=$(date +%Y%m%d-%H%M%S)
log_file=${DOTFILES_SYNC_LOG_FILE:-"$repo_dir/sync-$timestamp.log"}

dry_run=0
check_only=0
show_list=0

files=(
    .bashrc
    .bash_profile
    .profile
    .xprofile
    .gitconfig
    .gtkrc-2.0
    .vimrc
    .emacs
    .vim/colors/sway-rice.vim
    .config/environment.d/qt.conf
    .config/fastfetch/config.jsonc
    .config/foot/foot.ini
    .config/gtk-3.0/settings.ini
    .config/gtk-4.0/settings.ini
    .config/htop/htoprc
    .config/kanshi/config
    .config/mako/config
    .config/nvim/colors/sway-rice.lua
    .config/nvim/init.lua
    .config/nvim/lazy-lock.json
    .config/rofi/bluetooth
    .config/rofi/clipboard
    .config/rofi/config.rasi
    .config/rofi/files
    .config/rofi/launcher
    .config/rofi/mono.rasi
    .config/rofi/network
    .config/rofi/pipewire
    .config/rofi/pipewire-input
    .config/rofi/pipewire-output
    .config/rofi/power
    .config/starship.toml
    .config/sway/config
    .config/sway/scripts/battery-notify
    .config/sway/scripts/clipboard-watch
    .config/sway/scripts/lock
    .config/sway/scripts/screenshot
    .config/wallpapers/arch-cyber-abstract-monochrome.png
    .config/wallpapers/arch-thinkpad-cyber-monochrome.png
    .config/waybar/config.jsonc
    .config/waybar/scripts/pomodoro
    .config/waybar/style.css
)

usage() {
    cat <<'EOF'
Usage: ./sync-from-home.sh [options]

Copies the selected live dotfiles from $HOME back into this repo.
It never commits or pushes.

Options:
  --check            Report which files differ without copying.
  --list             Print the allowlist and exit.
  --log-file PATH    Write sync log to PATH.
  -n, --dry-run      Print actions without changing files.
  -h, --help         Show this help.

Environment:
  DOTFILES_SYNC_LOG_FILE    Log path. Default: ./sync-<timestamp>.log
EOF
}

log() {
    printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"
}

warn() {
    printf '[%s] warning: %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

die() {
    printf '[%s] error: %s\n' "$(date +%H:%M:%S)" "$*" >&2
    exit 1
}

setup_logging() {
    log_dir=$(dirname -- "$log_file")
    mkdir -p -- "$log_dir"
    touch "$log_file"
    exec > >(tee -a "$log_file") 2>&1
    log "Logging to $log_file"
}

run() {
    if [ "$dry_run" -eq 1 ]; then
        printf '[%s] dry-run:' "$(date +%H:%M:%S)"
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --check)
            check_only=1
            ;;
        --list)
            show_list=1
            ;;
        --log-file)
            [ "${2:-}" ] || die "--log-file requires a path"
            log_file=$2
            shift
            ;;
        -n|--dry-run)
            dry_run=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            die "unknown option: $1"
            ;;
    esac
    shift
done

if [ "$show_list" -eq 1 ]; then
    printf '%s\n' "${files[@]}"
    exit 0
fi

sync_file() {
    rel=$1
    src="$HOME/$rel"
    dest="$repo_dir/$rel"

    if [ ! -e "$src" ] && [ ! -L "$src" ]; then
        warn "missing in HOME: $rel"
        return 0
    fi

    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        log "current: $rel"
        return 0
    fi

    if [ "$check_only" -eq 1 ]; then
        log "differs: $rel"
        return 0
    fi

    run mkdir -p "$(dirname -- "$dest")"
    run cp -p -- "$src" "$dest"
    log "synced: $rel"
}

main() {
    setup_logging
    log "Repo: $repo_dir"
    log "Dry run: $dry_run"
    log "Check only: $check_only"

    count=0
    for rel in "${files[@]}"; do
        count=$((count + 1))
        sync_file "$rel"
    done

    log "Sync complete: $count allowlisted files processed"
    log "Review with: git -C '$repo_dir' status --short"
}

main "$@"
