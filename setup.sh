#!/usr/bin/env bash
# Set up the dotfiles on this machine. Idempotent, safe to run again after a pull.
#
# Adds the load lines to ~/.bashrc and ~/.gitconfig and links the config files.
# A file in the way with the same content is replaced by the link; otherwise the
# diff is shown and you choose to overwrite, back up or skip.
#
# Usage:
#   ~/dotfiles/setup.sh          # set up for the current user
#   ~/dotfiles/setup.sh --root   # also link the vimrc for root (sudo vim)

set -euo pipefail

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root=0
stamp="$(date +%Y-%m-%d_%H-%M-%S)"

usage() {
    sed -n '2,/^$/{s/^# \{0,1\}//;p}' "$0"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) root=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "setup.sh: unknown option $1" >&2; exit 2 ;;
    esac
    shift
done

# bashrc and profile refer to $HOME/dotfiles, so the repo has to live there
if [[ "$dotfiles" != "$HOME/dotfiles" ]]; then
    echo "setup.sh: expected the repo at $HOME/dotfiles, found $dotfiles" >&2
    exit 1
fi

# Print paths with ~ instead of $HOME
tildify() {
    local s="$*"
    printf '%s' "${s//$HOME/\~}"
}

# Ask overwrite/backup/skip on the terminal; skip if there is none
ask() {
    local answer
    if ! { : </dev/tty; } 2>/dev/null; then
        echo s
        return
    fi
    while true; do
        read -r -n 1 -p "          [o]verwrite, [b]ackup, [s]kip? " answer </dev/tty
        echo >&2
        case "$answer" in
            o|b|s) echo "$answer"; return ;;
        esac
    done
}

# link <src> <dst> [sudo]
link() {
    local src="$1" dst="$2" sudo="${3:-}"
    local name
    name="$(tildify "$dst")"

    if $sudo test -L "$dst" && [[ "$($sudo readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        echo "ok        $name"
        return
    fi

    if $sudo test -L "$dst" && ! $sudo test -e "$dst"; then
        echo "broken    $name, replaced"
        $sudo rm "$dst"
    elif $sudo test -e "$dst"; then
        if $sudo diff -rq "$dst" "$src" >/dev/null 2>&1; then
            echo "same      $name, replaced by link"
            $sudo rm -rf "$dst"
        else
            echo "differs   $name (- existing, + dotfiles):"
            $sudo diff -ru "$dst" "$src" | sed "s#$HOME#~#g; s/^/          /" || true
            case "$(ask)" in
                o) $sudo rm -rf "$dst" ;;
                b) $sudo mv "$dst" "$dst.bak-$stamp"
                   echo "backup    $name.bak-$stamp" ;;
                s) echo "skipped   $name"
                   return ;;
            esac
        fi
    fi

    $sudo mkdir -p "$(dirname "$dst")"
    $sudo ln -s "$src" "$dst"
    echo "linked    $name -> $(tildify "$src")"
}

# append_line <file> <marker> <line>: append <line> unless <marker> is already in <file>
append_line() {
    local file="$1" marker="$2" line="$3"
    if [[ -f "$file" ]] && grep -qF "$marker" "$file"; then
        echo "ok        $(tildify "$file")"
        return
    fi
    printf '\n%s\n' "$line" >> "$file"
    echo "added     $(tildify "$file"): $line"
}

append_line "$HOME/.bashrc" "dotfiles/bashrc" \
    '[ -f "$HOME/dotfiles/bashrc" ] && . "$HOME/dotfiles/bashrc"'

if git config --global --get-all include.path 2>/dev/null | grep -qF "dotfiles/gitconfig"; then
    echo "ok        ~/.gitconfig"
else
    git config --global --add include.path "~/dotfiles/gitconfig"
    echo "added     ~/.gitconfig: [include] ~/dotfiles/gitconfig"
fi

link "$dotfiles/.vimrc" "$HOME/.vimrc"

if command -v rofi >/dev/null; then
    link "$dotfiles/rofi-config.rasi" "$HOME/.config/rofi/config.rasi"
fi

if command -v ipython >/dev/null; then
    link "$dotfiles/.ipython/startup" "$HOME/.ipython/profile_default/startup"
fi

if [[ $root -eq 1 ]]; then
    link "$dotfiles/.vimrc" "/root/.vimrc" sudo
fi
