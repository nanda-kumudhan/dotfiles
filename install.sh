#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
backup_root=${DOTFILES_BACKUP_ROOT:-"$HOME/.dotfiles-backup"}
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$backup_root/$timestamp"
log_file=${DOTFILES_LOG_FILE:-"$backup_root/install-$timestamp.log"}

mode=link
install_deps=1
install_files=1
install_fonts=1
enable_services=0
assume_yes=0
dry_run=0
aur_helper=${DOTFILES_AUR_HELPER:-yay}
install_aur=1
use_arch_package_list=1

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Installs dependencies and deploys this dotfiles repo into $HOME with backups.

Options:
  --link              Symlink files into $HOME. Default.
  --copy              Copy files into $HOME instead of symlinking.
  --deps-only         Install packages/fonts only.
  --files-only        Deploy dotfiles only.
  --no-fonts          Skip JetBrainsMono Nerd Font fallback install.
  --no-aur            Skip AUR packages on Arch.
  --aur-helper NAME   AUR helper to bootstrap on Arch: yay or paru. Default: yay.
  --curated-packages  On Arch, use the built-in package list instead of packages.txt.
  --enable-services   Enable NetworkManager and bluetooth services if present.
  --log-file PATH     Write installer log to PATH.
  -y, --yes           Pass yes flags to package manager.
  -n, --dry-run       Print actions without changing anything.
  -h, --help          Show this help.

Environment:
  DOTFILES_BACKUP_ROOT    Backup directory root. Default: ~/.dotfiles-backup
  DOTFILES_LOG_FILE       Installer log path. Default: ~/.dotfiles-backup/install-<timestamp>.log
  DOTFILES_AUR_HELPER     AUR helper to use on Arch. Default: yay
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

section() {
    log ""
    log "==> $*"
}

quote_cmd() {
    printf '%q ' "$@"
}

setup_logging() {
    log_dir=$(dirname -- "$log_file")
    mkdir -p -- "$log_dir"
    touch "$log_file"
    exec > >(tee -a "$log_file") 2>&1
    log "Logging to $log_file"
}

run() {
    cmd=$(quote_cmd "$@")
    if [ "$dry_run" -eq 1 ]; then
        log "dry-run: $cmd"
    else
        log "run: $cmd"
        "$@"
    fi
}

run_shell() {
    if [ "$dry_run" -eq 1 ]; then
        printf '+ %s\n' "$*"
    else
        eval "$@"
    fi
}

as_root() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        run "$@"
    elif [ "$dry_run" -eq 1 ]; then
        run sudo "$@"
    elif command -v sudo >/dev/null 2>&1; then
        run sudo "$@"
    else
        die "sudo is required when not running as root"
    fi
}

confirm() {
    prompt=$1

    if [ "$assume_yes" -eq 1 ]; then
        log "auto-confirm: $prompt"
        return 0
    fi

    if [ -r /dev/tty ]; then
        printf '%s [y/N] ' "$prompt" > /dev/tty
        read -r answer < /dev/tty
    else
        warn "cannot prompt without a terminal: $prompt"
        return 1
    fi
    case "$answer" in
        y|Y|yes|YES|Yes)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --link)
            mode=link
            ;;
        --copy)
            mode=copy
            ;;
        --deps-only)
            install_files=0
            install_deps=1
            ;;
        --files-only)
            install_deps=0
            install_fonts=0
            install_files=1
            ;;
        --no-fonts)
            install_fonts=0
            ;;
        --no-aur)
            install_aur=0
            ;;
        --aur-helper)
            [ "${2:-}" ] || die "--aur-helper requires yay or paru"
            aur_helper=$2
            shift
            ;;
        --curated-packages)
            use_arch_package_list=0
            ;;
        --enable-services)
            enable_services=1
            ;;
        --log-file)
            [ "${2:-}" ] || die "--log-file requires a path"
            log_file=$2
            shift
            ;;
        -y|--yes)
            assume_yes=1
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

case "$aur_helper" in
    yay|paru)
        ;;
    *)
        die "--aur-helper must be yay or paru"
        ;;
esac

detect_family() {
    [ -r /etc/os-release ] || die "cannot detect distro: /etc/os-release missing"

    # shellcheck disable=SC1091
    . /etc/os-release
    id=${ID:-}
    like=${ID_LIKE:-}
    distro_words="$id $like"

    case " $distro_words " in
        *" arch "*|*" endeavouros "*|*" manjaro "*)
            printf 'arch'
            ;;
        *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*)
            printf 'debian'
            ;;
        *" fedora "*|*" rhel "*|*" centos "*)
            printf 'fedora'
            ;;
        *)
            die "unsupported distro family: ${PRETTY_NAME:-unknown}. Supported: Arch, Debian/Ubuntu, and Fedora family"
            ;;
    esac
}

arch_packages=(
    sway swayidle swaylock waybar foot rofi mako kanshi autotiling
    xdg-desktop-portal xdg-desktop-portal-wlr polkit-gnome udiskie
    networkmanager bluez bluez-utils blueman
    pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol
    brightnessctl playerctl grim slurp wl-clipboard cliphist
    fastfetch starship thunar keepassxc wdisplays htop mpv gnome-disk-utility
    libnotify jq git curl unzip xdg-utils openssh
    ttf-jetbrains-mono-nerd otf-font-awesome noto-fonts-emoji papirus-icon-theme
)

debian_packages=(
    sway swayidle swaylock waybar foot rofi mako-notifier kanshi autotiling
    xdg-desktop-portal xdg-desktop-portal-wlr policykit-1-gnome polkitd udiskie
    network-manager bluez bluetooth blueman
    pipewire pipewire-audio pipewire-pulse wireplumber pavucontrol
    brightnessctl playerctl grim slurp wl-clipboard cliphist
    fastfetch starship thunar keepassxc wdisplays htop mpv gnome-disk-utility
    libnotify-bin jq git curl unzip xdg-utils openssh-client dbus-user-session
    fonts-jetbrains-mono fonts-font-awesome fonts-noto-color-emoji papirus-icon-theme
)

fedora_packages=(
    sway swayidle swaylock waybar foot rofi mako kanshi
    xdg-desktop-portal xdg-desktop-portal-wlr polkit-gnome udiskie
    NetworkManager bluez blueman
    pipewire pipewire-alsa pipewire-pulseaudio wireplumber pavucontrol
    brightnessctl playerctl grim slurp wl-clipboard cliphist
    fastfetch starship thunar keepassxc wdisplays htop mpv gnome-disk-utility
    libnotify jq git curl unzip xdg-utils openssh-clients
    jetbrains-mono-fonts fontawesome-fonts-all google-noto-emoji-fonts papirus-icon-theme
)

filter_arch_packages() {
    available=()
    missing=()

    for pkg in "$@"; do
        if pacman -Si "$pkg" >/dev/null 2>&1; then
            available+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        warn "not in configured Arch repos: ${missing[*]}"
    fi

    printf '%s\n' "${available[@]}"
}

read_arch_package_list() {
    if [ "$use_arch_package_list" -eq 1 ] && [ -f "$repo_dir/packages.txt" ]; then
        sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$repo_dir/packages.txt" | sort -u
    else
        printf '%s\n' "${arch_packages[@]}" | sort -u
    fi
}

split_arch_packages() {
    repo_out=$1
    aur_out=$2
    : > "$repo_out"
    : > "$aur_out"

    while IFS= read -r pkg; do
        [ "$pkg" ] || continue
        case "$pkg" in
            "$aur_helper"|"$aur_helper"-debug|yay|yay-debug|paru|paru-debug|paru-bin|paru-bin-debug)
                continue
                ;;
        esac

        if pacman -Si "$pkg" >/dev/null 2>&1; then
            printf '%s\n' "$pkg" >> "$repo_out"
        else
            printf '%s\n' "$pkg" >> "$aur_out"
        fi
    done < <(read_arch_package_list)
}

install_arch_base_tools() {
    base=(base-devel git)

    missing=()
    for pkg in "${base[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    [ "${#missing[@]}" -gt 0 ] || return 0

    log "Required Arch bootstrap packages: ${missing[*]}"
    if confirm "Install Arch bootstrap packages with pacman?"; then
        args=(-S --needed)
        [ "$assume_yes" -eq 1 ] && args+=(--noconfirm)
        as_root pacman "${args[@]}" "${missing[@]}"
    else
        die "cannot continue without Arch bootstrap packages"
    fi
}

ensure_aur_helper() {
    [ "$install_aur" -eq 1 ] || return 0

    if command -v "$aur_helper" >/dev/null 2>&1; then
        log "AUR helper already available: $aur_helper"
        return 0
    fi

    install_arch_base_tools

    build_root=${DOTFILES_AUR_BUILD_DIR:-"${TMPDIR:-/tmp}/dotfiles-aur"}
    src_dir="$build_root/$aur_helper"
    aur_url="https://aur.archlinux.org/$aur_helper.git"

    log "AUR helper not found: $aur_helper"
    if ! confirm "Clone and build $aur_helper from AUR?"; then
        die "AUR helper is required for AUR package installation"
    fi

    if [ "$dry_run" -eq 1 ]; then
        log "dry-run: git clone $aur_url $src_dir"
        log "dry-run: makepkg -si in $src_dir"
        return 0
    fi

    mkdir -p "$build_root"
    if [ -d "$src_dir/.git" ]; then
        run git -C "$src_dir" pull --ff-only
    else
        run git clone "$aur_url" "$src_dir"
    fi

    makepkg_args=(-si)
    [ "$assume_yes" -eq 1 ] && makepkg_args+=(--noconfirm)
    run makepkg -C -f "${makepkg_args[@]}" -D "$src_dir"
}

install_arch_packages() {
    command -v pacman >/dev/null 2>&1 || die "pacman not found"

    repo_tmp=$(mktemp)
    aur_tmp=$(mktemp)
    split_arch_packages "$repo_tmp" "$aur_tmp"
    mapfile -t repo_packages < "$repo_tmp"
    mapfile -t aur_packages < "$aur_tmp"
    rm -f "$repo_tmp" "$aur_tmp"

    if [ "${#repo_packages[@]}" -gt 0 ]; then
        log "Arch repo packages from $([ "$use_arch_package_list" -eq 1 ] && printf packages.txt || printf built-in-list): ${#repo_packages[@]}"
        if confirm "Install ${#repo_packages[@]} Arch repo packages with pacman?"; then
            args=(-S --needed)
            [ "$assume_yes" -eq 1 ] && args+=(--noconfirm)
            as_root pacman "${args[@]}" "${repo_packages[@]}"
        else
            warn "skipped Arch repo packages"
        fi
    fi

    if [ "$install_aur" -eq 0 ]; then
        [ "${#aur_packages[@]}" -eq 0 ] || warn "skipped AUR packages because --no-aur was used: ${aur_packages[*]}"
        return 0
    fi

    if [ "${#aur_packages[@]}" -gt 0 ]; then
        log "AUR packages from packages.txt: ${#aur_packages[@]}"
        if confirm "Install ${#aur_packages[@]} AUR packages with $aur_helper?"; then
            ensure_aur_helper
            args=(-S --needed)
            [ "$assume_yes" -eq 1 ] && args+=(--noconfirm)
            run "$aur_helper" "${args[@]}" "${aur_packages[@]}"
        else
            warn "skipped AUR packages"
        fi
    fi
}

filter_debian_packages() {
    available=()
    missing=()

    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            available+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        warn "not in configured APT repos: ${missing[*]}"
    fi

    printf '%s\n' "${available[@]}"
}

filter_fedora_packages() {
    available=()
    missing=()

    for pkg in "$@"; do
        if dnf repoquery "$pkg" >/dev/null 2>&1; then
            available+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        warn "not in configured Fedora repos: ${missing[*]}"
    fi

    printf '%s\n' "${available[@]}"
}

install_packages() {
    family=$1
    section "Installing packages"

    case "$family" in
        arch)
            install_arch_packages
            ;;
        debian)
            command -v apt-get >/dev/null 2>&1 || die "apt-get not found"
            as_root apt-get update

            mapfile -t packages < <(filter_debian_packages "${debian_packages[@]}")
            [ "${#packages[@]}" -gt 0 ] || return 0
            log "Debian packages: ${#packages[@]}"

            args=(install)
            [ "$assume_yes" -eq 1 ] && args+=(-y)
            as_root apt-get "${args[@]}" "${packages[@]}"
            ;;
        fedora)
            command -v dnf >/dev/null 2>&1 || die "dnf not found"
            mapfile -t packages < <(filter_fedora_packages "${fedora_packages[@]}")
            [ "${#packages[@]}" -gt 0 ] || return 0
            log "Fedora packages: ${#packages[@]}"

            args=(install)
            [ "$assume_yes" -eq 1 ] && args+=(-y)
            as_root dnf "${args[@]}" "${packages[@]}"
            ;;
    esac
}

install_nerd_font_fallback() {
    section "Checking fonts"
    [ "$install_fonts" -eq 1 ] || return 0

    if command -v fc-match >/dev/null 2>&1 && fc-match "JetBrainsMono Nerd Font" | grep -qi 'JetBrainsMono.*Nerd'; then
        log "JetBrainsMono Nerd Font already available"
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
        warn "curl and unzip are required to install JetBrainsMono Nerd Font fallback"
        return 0
    fi

    font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    zip_file="${TMPDIR:-/tmp}/JetBrainsMonoNerdFont.zip"
    url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

    log "Installing JetBrainsMono Nerd Font fallback into $font_dir"
    run mkdir -p "$font_dir"
    run curl -L --fail -o "$zip_file" "$url"
    run unzip -o "$zip_file" '*.ttf' -d "$font_dir"

    if command -v fc-cache >/dev/null 2>&1; then
        run fc-cache -f "$font_dir"
    fi
}

enable_common_services() {
    section "Enabling services"
    [ "$enable_services" -eq 1 ] || return 0
    command -v systemctl >/dev/null 2>&1 || return 0

    for service in NetworkManager bluetooth; do
        if systemctl list-unit-files "$service.service" 2>/dev/null | grep -q "^$service\\.service"; then
            as_root systemctl enable --now "$service.service"
        else
            warn "service not found: $service.service"
        fi
    done
}

ensure_backup_dir() {
    [ -d "$backup_dir" ] || run mkdir -p "$backup_dir"
}

backup_path() {
    dest=$1
    rel=${dest#"$HOME"/}
    backup="$backup_dir/$rel"

    log "backup: $rel -> ${backup#"$HOME"/}"
    ensure_backup_dir
    run mkdir -p "$(dirname -- "$backup")"
    run mv -- "$dest" "$backup"
}

same_symlink() {
    dest=$1
    src=$2

    [ -L "$dest" ] || return 1
    target=$(readlink -- "$dest")
    [ "$target" = "$src" ]
}

deploy_file() {
    src=$1
    rel=${src#"$repo_dir"/}
    dest="$HOME/$rel"

    case "$rel" in
        .git/*|.git|.gitignore|README|README.*|install.sh|bootstrap.sh|sync-from-home.sh)
            return 0
            ;;
    esac

    run mkdir -p "$(dirname -- "$dest")"

    if [ "$mode" = link ]; then
        if same_symlink "$dest" "$src"; then
            log "linked: $rel"
            return 0
        fi

        if [ -e "$dest" ] || [ -L "$dest" ]; then
            backup_path "$dest"
        fi

        run ln -s -- "$src" "$dest"
        log "linked: $rel"
        return 0
    fi

    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        log "current: $rel"
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup_path "$dest"
    fi

    run cp -p -- "$src" "$dest"
    log "copied: $rel"
}

deploy_dotfiles() {
    section "Deploying dotfiles"
    files=0

    while IFS= read -r -d '' src; do
        files=$((files + 1))
        deploy_file "$src"
    done < <(
        find "$repo_dir" -type f \
            ! -path "$repo_dir/.git/*" \
            ! -name 'README' \
            ! -name 'README.*' \
            ! -name 'install.sh' \
            ! -name 'sync-from-home.sh' \
            ! -name '.gitignore' \
            -print0
    )

    if [ -d "$backup_dir" ]; then
        log "Backups written to $backup_dir"
    fi

    log "Deployment complete: $files files processed"
}

warn_if_home_differs() {
    old_home="/home/nanda-kumudhan"
    if [ "$HOME" != "$old_home" ] && grep -R "$old_home" "$repo_dir" \
        --exclude-dir=.git --exclude=install.sh >/dev/null 2>&1; then
        warn "some dotfiles contain hardcoded paths for $old_home; review them after install"
    fi
}

main() {
    setup_logging

    family=$(detect_family)
    section "Dotfiles installer"
    log "Detected distro family: $family"
    log "Repo: $repo_dir"
    log "Deploy mode: $mode"
    log "Dry run: $dry_run"
    log "Backup root: $backup_root"

    if [ "$install_deps" -eq 1 ]; then
        install_packages "$family"
        install_nerd_font_fallback
        enable_common_services
    fi

    if [ "$install_files" -eq 1 ]; then
        warn_if_home_differs
        deploy_dotfiles
    fi

    log "Done."
}

main "$@"
