#!/usr/bin/env bash
set -euo pipefail

repo_url=${DOTFILES_REPO_URL:-https://github.com/nanda-kumudhan/dotfiles.git}
repo_dir=${DOTFILES_REPO_DIR:-"$HOME/Github/dotfiles"}

as_root() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        printf 'error: sudo is required when not running as root\n' >&2
        exit 1
    fi
}

install_bootstrap_deps() {
    command -v git >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 && return 0

    . /etc/os-release
    words=" ${ID:-} ${ID_LIKE:-} "

    case "$words" in
        *" arch "*|*" endeavouros "*|*" manjaro "*)
            as_root pacman -S --needed --noconfirm git curl
            ;;
        *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*)
            as_root apt-get update
            as_root apt-get install -y git curl
            ;;
        *" fedora "*|*" rhel "*|*" centos "*)
            as_root dnf install -y git curl
            ;;
        *)
            printf 'error: unsupported distro family: %s\n' "${PRETTY_NAME:-unknown}" >&2
            exit 1
            ;;
    esac
}

install_bootstrap_deps
mkdir -p "$(dirname -- "$repo_dir")"

if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" pull --ff-only
else
    git clone "$repo_url" "$repo_dir"
fi

exec "$repo_dir/install.sh" "$@"
