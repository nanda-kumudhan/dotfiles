#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
backup_root=${DOTFILES_BACKUP_ROOT:-"$HOME/.dotfiles-backup"}
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$backup_root/$timestamp"
log_file=${DOTFILES_LOG_FILE:-"$backup_root/install-$timestamp.log"}

mode=link
install_deps=1
install_files=1
install_fonts=1
install_themes=1
enable_services=0
assume_yes=0
dry_run=0
aur_helper=${DOTFILES_AUR_HELPER:-yay}
install_aur=1
use_arch_package_list=1
warning_count=0
current_stage="initialization"
install_started_at=$SECONDS
temporary_paths=()
active_command=

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Installs dependencies and deploys this dotfiles repo into $HOME with backups.
Supports Arch Linux only.

Options:
  --link              Symlink files into $HOME. Default.
  --copy              Copy files into $HOME instead of symlinking.
  --deps-only         Install packages, fonts, and themes only.
  --files-only        Deploy dotfiles only.
  --no-fonts          Skip JetBrainsMono Nerd Font fallback install.
  --no-themes         Skip Papirus and Gruvbox theme fallback installs.
  --no-aur            Skip AUR packages.
  --aur-helper NAME   AUR helper to bootstrap: yay or paru. Default: yay.
  --curated-packages  Use the built-in package list instead of packages.txt.
  --enable-services   Enable NetworkManager and bluetooth services if present.
  --log-file PATH     Write installer log to PATH.
  -y, --yes           Pass yes flags to package manager.
  -n, --dry-run       Print actions without changing anything.
  -h, --help          Show this help.

Environment:
  DOTFILES_BACKUP_ROOT    Backup directory root. Default: ~/.dotfiles-backup
  DOTFILES_LOG_FILE       Installer log path. Default: ~/.dotfiles-backup/install-<timestamp>.log
  DOTFILES_AUR_HELPER     AUR helper to use. Default: yay
EOF
}

log() {
    printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"
}

warn() {
    active_command=
    warning_count=$((warning_count + 1))
    printf '[%s] warning: %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

die() {
    printf '[%s] error: %s\n' "$(date +%H:%M:%S)" "$*" >&2
    exit 1
}

section() {
    current_stage=$*
    log ""
    log "==> $*"
}

register_temp() {
    temporary_paths+=("$1")
}

cleanup() {
    local path

    for path in "${temporary_paths[@]:-}"; do
        [ -n "$path" ] || continue
        rm -rf -- "$path" 2>/dev/null || true
    done
}

on_error() {
    local status=$?
    local line=${BASH_LINENO[0]:-unknown}
    local command=${active_command:-${BASH_COMMAND:-unknown}}

    printf '[%s] error: stage failed: %s\n' "$(date +%H:%M:%S)" "$current_stage" >&2
    printf '[%s] error: command exited with status %s at line %s: %s\n' \
        "$(date +%H:%M:%S)" "$status" "$line" "$command" >&2
    printf '[%s] error: review the log for the preceding command output: %s\n' \
        "$(date +%H:%M:%S)" "$log_file" >&2
    exit "$status"
}

on_exit() {
    local status=$?
    cleanup

    if [ "$status" -ne 0 ]; then
        printf '[%s] error: installer stopped with status %s during: %s\n' \
            "$(date +%H:%M:%S)" "$status" "$current_stage" >&2
    fi
}

trap on_error ERR
trap on_exit EXIT

quote_cmd() {
    printf '%q ' "$@"
}

setup_logging() {
    if [ "$dry_run" -eq 1 ]; then
        log "Dry run: log file creation skipped"
        return 0
    fi

    log_dir=$(dirname -- "$log_file")
    mkdir -p -- "$log_dir"
    touch "$log_file"
    exec > >(tee -a "$log_file") 2>&1
    log "Logging to $log_file"
}

run() {
    local cmd
    local started_at=$SECONDS
    local status

    cmd=$(quote_cmd "$@")
    if [ "$dry_run" -eq 1 ]; then
        log "dry-run: $cmd"
    else
        log "run: $cmd"
        active_command=$cmd
        if "$@"; then
            active_command=
            log "ok ($((SECONDS - started_at))s): $cmd"
        else
            status=$?
            warning_count=$((warning_count + 1))
            printf '[%s] warning: failed with status %s after %ss: %s\n' \
                "$(date +%H:%M:%S)" "$status" "$((SECONDS - started_at))" "$cmd" >&2
            return "$status"
        fi
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

install_individually_on_failure() {
    local label=$1
    local runner=$2
    shift 2
    local -a prefix=()
    local -a packages=()
    local -a failed=()
    local parsing_packages=0
    local item

    for item in "$@"; do
        if [ "$item" = "--" ]; then
            parsing_packages=1
        elif [ "$parsing_packages" -eq 0 ]; then
            prefix+=("$item")
        else
            packages+=("$item")
        fi
    done

    [ "${#packages[@]}" -gt 0 ] || return 0

    log "$label: attempting batch install of ${#packages[@]} package(s)"
    if "$runner" "${prefix[@]}" "${packages[@]}"; then
        log "$label: batch install completed"
        return 0
    fi

    warn "$label batch install failed; retrying each package separately"
    for item in "${packages[@]}"; do
        log "$label: installing package: $item"
        if "$runner" "${prefix[@]}" "$item"; then
            log "$label: installed package: $item"
        else
            failed+=("$item")
            warn "$label: could not install package: $item"
        fi
    done

    if [ "${#failed[@]}" -gt 0 ]; then
        warn "$label completed with ${#failed[@]} failed package(s): ${failed[*]}"
    else
        log "$label: all packages installed successfully after individual retries"
    fi

    return 0
}

confirm() {
    prompt=$1

    if [ "$assume_yes" -eq 1 ]; then
        log "auto-confirm: $prompt"
        return 0
    fi

    answer=
    if [ -r /dev/tty ] && { printf '%s [y/N] ' "$prompt" > /dev/tty; } 2>/dev/null; then
        if ! read -r answer < /dev/tty 2>/dev/null; then
            warn "cannot read confirmation from terminal: $prompt"
            return 1
        fi
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
            install_themes=0
            install_files=1
            ;;
        --no-fonts)
            install_fonts=0
            ;;
        --no-themes)
            install_themes=0
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

require_arch() {
    [ -r /etc/os-release ] || die "cannot detect distro: /etc/os-release missing"

    # shellcheck disable=SC1091
    . /etc/os-release
    id=${ID:-}
    like=${ID_LIKE:-}
    distro_words="$id $like"

    case " $distro_words " in
        *" arch "*|*" endeavouros "*|*" manjaro "*)
            ;;
        *)
            die "unsupported system: ${PRETTY_NAME:-unknown}. These dotfiles support Arch Linux only"
            ;;
    esac

    command -v pacman >/dev/null 2>&1 || die "pacman not found"
}

arch_packages=(
    sway swayidle swaylock waybar foot rofi mako kanshi autotiling
    xdg-desktop-portal xdg-desktop-portal-wlr polkit-gnome udiskie
    networkmanager bluez bluez-utils blueman
    pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol
    brightnessctl playerctl grim slurp wl-clipboard cliphist
    fastfetch starship thunar keepassxc wdisplays htop mpv gnome-disk-utility
    libnotify jq git curl unzip xdg-utils openssh pciutils
    ttf-jetbrains-mono-nerd otf-font-awesome noto-fonts-emoji papirus-icon-theme
)

arch_driver_packages() {
    packages=()
    gpu_info=
    cpu_info=

    if command -v lspci >/dev/null 2>&1; then
        gpu_info=$(lspci -nn | grep -Ei 'VGA|3D|Display' || true)
    else
        warn "lspci not found; install pciutils to enable GPU driver detection"
    fi

    if [ -r /proc/cpuinfo ]; then
        cpu_info=$(grep -m1 '^vendor_id' /proc/cpuinfo || true)
    fi

    if printf '%s\n' "$gpu_info" | grep -Eiq 'Intel Corporation'; then
        packages+=(intel-media-driver libva-intel-driver vulkan-intel mesa)
    fi

    if printf '%s\n' "$gpu_info" | grep -Eiq 'AMD/ATI|Advanced Micro Devices'; then
        packages+=(mesa vulkan-radeon libva-mesa-driver mesa-vdpau xf86-video-amdgpu)
    fi

    if printf '%s\n' "$gpu_info" | grep -Eiq 'NVIDIA Corporation'; then
        packages+=(nvidia-utils nvidia-settings)
        pacman -Q linux >/dev/null 2>&1 && packages+=(nvidia)
        pacman -Q linux-lts >/dev/null 2>&1 && packages+=(nvidia-lts)
    fi

    if printf '%s\n' "$cpu_info" | grep -q 'GenuineIntel'; then
        packages+=(intel-ucode)
    elif printf '%s\n' "$cpu_info" | grep -q 'AuthenticAMD'; then
        packages+=(amd-ucode)
    fi

    printf '%s\n' "${packages[@]}"
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

    driver_tmp=$(mktemp)
    register_temp "$driver_tmp"
    arch_driver_packages > "$driver_tmp"
    print_package_group "Detected hardware driver packages" "$driver_tmp"

    mapfile -t package_candidates < <({ read_arch_package_list; cat "$driver_tmp"; } | sort -u)
    total=${#package_candidates[@]}
    current=0

    log "Classifying $total Arch package names into repo/AUR groups"

    for pkg in "${package_candidates[@]}"; do
        [ "$pkg" ] || continue
        current=$((current + 1))
        log "checking package $current/$total: $pkg"

        case "$pkg" in
            "$aur_helper"|"$aur_helper"-debug|yay|yay-debug|paru|paru-debug|paru-bin|paru-bin-debug)
                log "skipping AUR helper package entry: $pkg"
                continue
                ;;
        esac

        if pacman -Si "$pkg" >/dev/null 2>&1; then
            printf '%s\n' "$pkg" >> "$repo_out"
            log "repo package: $pkg"
        else
            printf '%s\n' "$pkg" >> "$aur_out"
            log "AUR package: $pkg"
        fi
    done

    log "Package classification complete"
    rm -f "$driver_tmp"
}

split_installed_packages() {
    input=$1
    installed_out=$2
    missing_out=$3
    : > "$installed_out"
    : > "$missing_out"

    while IFS= read -r pkg; do
        [ "$pkg" ] || continue
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            printf '%s\n' "$pkg" >> "$installed_out"
        else
            printf '%s\n' "$pkg" >> "$missing_out"
        fi
    done < "$input"
}

print_package_group() {
    title=$1
    file=$2

    if [ ! -s "$file" ]; then
        log "$title: none"
        return 0
    fi

    count=$(wc -l < "$file")
    log "$title ($count):"
    sed 's/^/  - /' "$file"
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

    run mkdir -p "$build_root"
    if [ -d "$src_dir/.git" ]; then
        if ! run git -C "$src_dir" pull --ff-only; then
            warn "failed to update the existing $aur_helper checkout; rebuilding the current checkout"
        fi
    else
        if ! run git clone "$aur_url" "$src_dir"; then
            warn "failed to clone $aur_helper; skipping AUR packages"
            return 1
        fi
    fi

    makepkg_args=(-si)
    [ "$assume_yes" -eq 1 ] && makepkg_args+=(--noconfirm)
    run makepkg -C -f "${makepkg_args[@]}" -D "$src_dir"
}

install_arch_packages() {
    command -v pacman >/dev/null 2>&1 || die "pacman not found"

    log "Preparing Arch package install plan"

    repo_tmp=$(mktemp)
    aur_tmp=$(mktemp)
    repo_installed_tmp=$(mktemp)
    repo_missing_tmp=$(mktemp)
    aur_installed_tmp=$(mktemp)
    aur_missing_tmp=$(mktemp)
    register_temp "$repo_tmp"
    register_temp "$aur_tmp"
    register_temp "$repo_installed_tmp"
    register_temp "$repo_missing_tmp"
    register_temp "$aur_installed_tmp"
    register_temp "$aur_missing_tmp"
    split_arch_packages "$repo_tmp" "$aur_tmp"
    log "Checking which repo packages are already installed"
    split_installed_packages "$repo_tmp" "$repo_installed_tmp" "$repo_missing_tmp"
    log "Checking which AUR packages are already installed"
    split_installed_packages "$aur_tmp" "$aur_installed_tmp" "$aur_missing_tmp"
    mapfile -t repo_packages < "$repo_missing_tmp"
    mapfile -t aur_packages < "$aur_missing_tmp"

    log "Arch package source: $([ "$use_arch_package_list" -eq 1 ] && printf packages.txt || printf built-in-list)"
    print_package_group "Already installed repo packages" "$repo_installed_tmp"
    print_package_group "Repo packages to install with pacman" "$repo_missing_tmp"

    if [ "${#repo_packages[@]}" -gt 0 ]; then
        if confirm "Continue installing ${#repo_packages[@]} missing Arch repo packages with pacman?"; then
            args=(-S --needed)
            [ "$assume_yes" -eq 1 ] && args+=(--noconfirm)
            install_individually_on_failure \
                "pacman repository packages" as_root \
                pacman "${args[@]}" -- "${repo_packages[@]}"
        else
            warn "skipped Arch repo packages"
        fi
    fi

    print_package_group "Already installed AUR packages" "$aur_installed_tmp"
    print_package_group "AUR packages to install with $aur_helper" "$aur_missing_tmp"

    if [ "$install_aur" -eq 0 ]; then
        [ ! -s "$aur_missing_tmp" ] || warn "skipped missing AUR packages because --no-aur was used: $(tr '\n' ' ' < "$aur_missing_tmp")"
        rm -f "$repo_tmp" "$aur_tmp" "$repo_installed_tmp" "$repo_missing_tmp" "$aur_installed_tmp" "$aur_missing_tmp"
        return 0
    fi

    if [ "${#aur_packages[@]}" -gt 0 ]; then
        if confirm "Continue installing ${#aur_packages[@]} missing AUR packages with $aur_helper?"; then
            if ensure_aur_helper; then
                args=(-S --needed)
                [ "$assume_yes" -eq 1 ] && args+=(--noconfirm)
                install_individually_on_failure \
                    "$aur_helper AUR packages" run \
                    "$aur_helper" "${args[@]}" -- "${aur_packages[@]}"
            else
                warn "AUR helper setup failed; skipping AUR packages"
            fi
        else
            warn "skipped AUR packages"
        fi
    fi

    rm -f "$repo_tmp" "$aur_tmp" "$repo_installed_tmp" "$repo_missing_tmp" "$aur_installed_tmp" "$aur_missing_tmp"
}

install_packages() {
    section "Installing packages"
    install_arch_packages
}

install_nerd_font_fallback() {
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    local archive
    local staging_dir
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

    section "Checking fonts"
    if [ "$install_fonts" -ne 1 ]; then
        log "Nerd Font fallback disabled; skipping"
        return 0
    fi

    if command -v fc-list >/dev/null 2>&1 \
        && fc-list : family | grep -Ei 'JetBrains ?Mono (Nerd Font|NF)' >/dev/null; then
        log "JetBrainsMono Nerd Font already available"
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
        warn "curl and unzip are required to download JetBrainsMono Nerd Font"
        return 0
    fi

    if [ "$dry_run" -eq 1 ]; then
        archive="${TMPDIR:-/tmp}/JetBrainsMonoNerdFont.zip"
        staging_dir="${TMPDIR:-/tmp}/JetBrainsMonoNerdFont.extract"
    else
        if ! archive=$(mktemp "${TMPDIR:-/tmp}/JetBrainsMonoNerdFont.XXXXXX.zip") \
            || ! staging_dir=$(mktemp -d "${TMPDIR:-/tmp}/JetBrainsMonoNerdFont.XXXXXX"); then
            warn "failed to create temporary files for JetBrainsMono Nerd Font"
            [ -z "${archive:-}" ] || rm -f "$archive"
            return 0
        fi
        register_temp "$archive"
        register_temp "$staging_dir"
    fi

    log "Downloading JetBrainsMono Nerd Font from the official Nerd Fonts release"
    if ! run curl --fail --location --retry 3 --output "$archive" "$url"; then
        warn "failed to download JetBrainsMono Nerd Font; continuing without it"
        run rm -rf "$staging_dir" "$archive"
        return 0
    fi

    if ! run unzip -j -o "$archive" '*.ttf' -d "$staging_dir"; then
        warn "failed to extract JetBrainsMono Nerd Font; continuing without it"
        run rm -rf "$staging_dir" "$archive"
        return 0
    fi

    if [ "$dry_run" -eq 0 ] && ! find "$staging_dir" -type f -name '*.ttf' -print -quit | grep -q .; then
        warn "JetBrainsMono Nerd Font archive did not contain TTF files"
        run rm -rf "$staging_dir" "$archive"
        return 0
    fi

    log "Installing JetBrainsMono Nerd Font into $font_dir"
    if ! run mkdir -p "$(dirname -- "$font_dir")" \
        || ! run rm -rf "$font_dir" \
        || ! run mv "$staging_dir" "$font_dir"; then
        warn "failed to install JetBrainsMono Nerd Font; continuing"
        run rm -rf "$staging_dir" "$archive"
        return 0
    fi

    if ! run rm -f "$archive"; then
        warn "could not remove the downloaded font archive; exit cleanup will retry"
    fi

    if command -v fc-cache >/dev/null 2>&1; then
        if ! run fc-cache -f "$font_dir"; then
            warn "JetBrainsMono Nerd Font was installed, but refreshing the font cache failed"
        fi
    fi

    log "JetBrainsMono Nerd Font installed"
}

clone_or_update_theme_repo() {
    local url=$1
    local dest=$2
    local name=$3

    if [ "$dry_run" -eq 1 ]; then
        log "dry-run: clone or update $name from $url into $dest"
        return 0
    fi

    if [ -d "$dest/.git" ]; then
        if ! run git -C "$dest" pull --ff-only; then
            warn "failed to update $name; using the existing checkout"
        fi
        return 0
    fi

    if ! run rm -rf "$dest"; then
        warn "failed to clear the old $name checkout"
        return 1
    fi
    if ! run git clone --depth 1 "$url" "$dest"; then
        warn "failed to clone $name"
        return 1
    fi
}

install_papirus_theme() {
    local cache_root="$HOME/.cache/dotfiles-themes"
    local icons_dir="$HOME/.local/share/icons"
    local papirus_repo="$cache_root/papirus-icon-theme"
    local folders_repo="$cache_root/papirus-folders"
    local folders_bin="$HOME/.local/bin/papirus-folders"
    local theme

    log "Papirus source: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme"
    log "Papirus destination: $icons_dir"

    if [ ! -d "$icons_dir/Papirus-Dark" ]; then
        log "Installing Papirus icon themes into $icons_dir"
        clone_or_update_theme_repo \
            "https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git" \
            "$papirus_repo" "Papirus icon theme" || return 0

        if ! run mkdir -p "$icons_dir"; then
            warn "failed to create the user icon directory"
            return 0
        fi

        for theme in Papirus Papirus-Dark Papirus-Light; do
            if [ "$dry_run" -eq 1 ] || [ -d "$papirus_repo/$theme" ]; then
                if ! run rm -rf "$icons_dir/$theme" \
                    || ! run cp -a "$papirus_repo/$theme" "$icons_dir/$theme"; then
                    warn "failed to install the $theme icon theme"
                    return 0
                fi
            fi
        done
    else
        log "Papirus-Dark icon theme already installed locally"
    fi

    if [ ! -x "$folders_bin" ]; then
        clone_or_update_theme_repo \
            "https://github.com/PapirusDevelopmentTeam/papirus-folders.git" \
            "$folders_repo" "Papirus Folders" || return 0

        if ! run mkdir -p "$(dirname -- "$folders_bin")" \
            || ! run install -m 0755 "$folders_repo/papirus-folders" "$folders_bin"; then
            warn "failed to install papirus-folders"
            return 0
        fi
    fi

    log "Applying grey folders to Papirus-Dark"
    if ! run "$folders_bin" -C grey --theme Papirus-Dark; then
        warn "failed to apply grey Papirus folders"
    fi

    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        if ! run gtk-update-icon-cache -f "$icons_dir/Papirus-Dark"; then
            warn "failed to refresh the Papirus-Dark icon cache"
        fi
    fi
}

install_gruvbox_gtk_theme() {
    local cache_root="$HOME/.cache/dotfiles-themes"
    local themes_dir="$HOME/.local/share/themes"
    local gruvbox_repo="$cache_root/Gruvbox-GTK-Theme"
    local theme_dir="$themes_dir/gruvbox-dark-gtk"
    local generated_theme

    log "Gruvbox source: https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme"
    log "Gruvbox destination: $themes_dir"

    if [ -d "$theme_dir" ]; then
        log "Gruvbox GTK theme already installed locally"
        return 0
    fi

    clone_or_update_theme_repo \
        "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git" \
        "$gruvbox_repo" "Gruvbox GTK theme" || return 0

    log "Installing Gruvbox GTK theme into $themes_dir"
    if ! run mkdir -p "$themes_dir"; then
        warn "failed to create the user theme directory"
        return 0
    fi

    if [ "$dry_run" -eq 1 ]; then
        log "dry-run: run the Gruvbox installer for a dark theme named gruvbox-dark-gtk"
        return 0
    fi

    if ! (
        cd "$gruvbox_repo/themes"
        printf '[%s] run: Gruvbox upstream installer\n' "$(date +%H:%M:%S)"
        ./install.sh -d "$themes_dir" -n gruvbox-dark-gtk -c dark
    ); then
        warn "failed to install the Gruvbox GTK theme; continuing"
        return 0
    fi

    if [ ! -d "$theme_dir" ]; then
        if [ -d "$themes_dir/gruvbox-dark-gtk-Dark" ]; then
            generated_theme="$themes_dir/gruvbox-dark-gtk-Dark"
        else
            generated_theme=$(find "$themes_dir" -mindepth 1 -maxdepth 1 -type d \
                -name 'gruvbox-dark-gtk*' ! -name '*-hdpi' ! -name '*-xhdpi' \
                -print -quit)
        fi
        if [ -n "$generated_theme" ]; then
            if ! run ln -s "$(basename -- "$generated_theme")" "$theme_dir"; then
                warn "failed to create the gruvbox-dark-gtk theme alias"
            fi
        else
            warn "Gruvbox installer did not create the expected theme"
        fi
    fi
}

install_theme_fallbacks() {
    section "Checking desktop themes"
    if [ "$install_themes" -ne 1 ]; then
        log "Desktop theme fallbacks disabled; skipping"
        return 0
    fi

    if ! command -v git >/dev/null 2>&1; then
        warn "git is required to install desktop theme fallbacks"
        return 0
    fi

    install_papirus_theme
    install_gruvbox_gtk_theme
    log "Desktop theme checks complete"
}

enable_common_services() {
    section "Enabling services"
    if [ "$enable_services" -ne 1 ]; then
        log "Service enablement not requested; skipping"
        return 0
    fi
    if ! command -v systemctl >/dev/null 2>&1; then
        warn "systemctl not found; skipping service enablement"
        return 0
    fi

    for service in NetworkManager bluetooth; do
        if systemctl list-unit-files "$service.service" 2>/dev/null | grep -q "^$service\\.service"; then
            log "Enabling service: $service.service"
            if ! as_root systemctl enable --now "$service.service"; then
                warn "failed to enable service: $service.service"
            fi
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
        find "$repo_dir" -mindepth 1 -type f \
            -path "$repo_dir/.*" \
            ! -path "$repo_dir/.git/*" \
            ! -name '.gitignore' \
            -print0
    )

    if [ -d "$backup_dir" ]; then
        log "Backups written to $backup_dir"
    fi

    log "Deployment complete: $files files processed"
}

main() {
    setup_logging

    require_arch
    section "Dotfiles installer"
    log "Started: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    log "Platform: Arch Linux"
    log "Repo: $repo_dir"
    log "Home: $HOME"
    log "Deploy mode: $mode"
    log "Dry run: $dry_run"
    log "Install dependencies: $install_deps"
    log "Install dotfiles: $install_files"
    log "Install Nerd Font fallback: $install_fonts"
    log "Install theme fallbacks: $install_themes"
    log "Enable services: $enable_services"
    log "Install AUR packages: $install_aur"
    log "Backup root: $backup_root"

    if [ "$install_deps" -eq 1 ]; then
        install_packages
        log "Package stage complete"
        install_nerd_font_fallback
        log "Font stage complete"
        install_theme_fallbacks
        log "Theme stage complete"
        enable_common_services
        log "Service stage complete"
    else
        log "Skipping packages, fonts, themes, and services"
    fi

    if [ "$install_files" -eq 1 ]; then
        deploy_dotfiles
    else
        log "Skipping dotfile deployment"
    fi

    current_stage="complete"
    log ""
    log "==> Installation summary"
    log "Result: completed"
    log "Elapsed time: $((SECONDS - install_started_at)) seconds"
    log "Warnings: $warning_count"
    if [ "$dry_run" -eq 0 ]; then
        log "Log file: $log_file"
    fi
    if [ "$warning_count" -gt 0 ]; then
        log "Completed with warnings; review the warning lines above"
    else
        log "Completed without warnings"
    fi
}

main "$@"
