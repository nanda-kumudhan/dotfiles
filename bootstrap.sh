#!/usr/bin/env bash
set -Eeuo pipefail

repo_url=${DOTFILES_REPO_URL:-https://github.com/nanda-kumudhan/dotfiles.git}
repo_dir=${DOTFILES_REPO_DIR:-"$HOME/Github/dotfiles"}
bootstrap_step="initialization"

log() {
    printf '[bootstrap] %s\n' "$*"
}

warn() {
    printf '[bootstrap] warning: %s\n' "$*" >&2
}

die() {
    printf '[bootstrap] error: %s\n' "$*" >&2
    exit 1
}

on_error() {
    local status=$?
    local line=${BASH_LINENO[0]:-unknown}
    local command=${BASH_COMMAND:-unknown}

    printf '[bootstrap] error: step failed: %s\n' "$bootstrap_step" >&2
    printf '[bootstrap] error: command exited with status %s at line %s: %s\n' \
        "$status" "$line" "$command" >&2
    printf '[bootstrap] error: repository destination: %s\n' "$repo_dir" >&2
    exit "$status"
}

trap on_error ERR

as_root() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        die "sudo is required when not running as root"
    fi
}

install_bootstrap_deps() {
    bootstrap_step="checking bootstrap dependencies"
    if command -v git >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
        log "Required tools already available: git and curl"
        return 0
    fi

    [ -r /etc/os-release ] || {
        die "cannot detect distro: /etc/os-release missing"
    }
    . /etc/os-release
    words=" ${ID:-} ${ID_LIKE:-} "
    log "Detected system: ${PRETTY_NAME:-unknown}"
    log "Installing bootstrap dependencies"

    case "$words" in
        *" arch "*|*" endeavouros "*|*" manjaro "*)
            log "Using pacman to install git and curl"
            as_root pacman -S --needed --noconfirm git curl
            ;;
        *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*)
            log "Refreshing APT package indexes"
            if ! as_root apt-get update; then
                warn "APT package index refresh failed; trying the existing package index"
            fi
            log "Using APT to install git and curl"
            as_root apt-get install -y git curl
            ;;
        *" fedora "*|*" rhel "*|*" centos "*)
            log "Using DNF to install git and curl"
            as_root dnf install -y git curl
            ;;
        *)
            die "unsupported distro family: ${PRETTY_NAME:-unknown}"
            ;;
    esac
}

log "Dotfiles bootstrap starting"
log "Repository: $repo_url"
log "Destination: $repo_dir"
install_bootstrap_deps
bootstrap_step="creating repository destination"
log "Ensuring destination parent exists"
mkdir -p "$(dirname -- "$repo_dir")"

if [ -d "$repo_dir/.git" ]; then
    bootstrap_step="updating existing repository"
    log "Existing clone found; updating with fast-forward only"
    git -C "$repo_dir" pull --ff-only
else
    bootstrap_step="cloning repository"
    log "Cloning dotfiles repository"
    git clone "$repo_url" "$repo_dir"
fi

bootstrap_step="starting installer"
log "Starting installer with arguments: $*"
exec "$repo_dir/install.sh" "$@"
