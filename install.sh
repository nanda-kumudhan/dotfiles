#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link_file() {
    local src=$1
    local rel=${src#"$repo_dir"/}
    local dest="$HOME/$rel"

    mkdir -p -- "$(dirname -- "$dest")"

    if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p -- "$backup_dir/$(dirname -- "$rel")"
        mv -- "$dest" "$backup_dir/$rel"
    fi

    ln -s -- "$src" "$dest"
}

while IFS= read -r -d '' file; do
    case "${file#"$repo_dir"/}" in
        .git/*|.gitignore|README.md|install.sh) continue ;;
    esac

    link_file "$file"
done < <(find "$repo_dir" -type f -print0)

if [ -d "$backup_dir" ]; then
    printf 'Backed up replaced files to %s\n' "$backup_dir"
fi

printf 'Dotfiles linked from %s\n' "$repo_dir"
