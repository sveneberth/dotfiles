# Entry point, loaded from ~/.bashrc. Pulls in the environment first and
# the aliases last, so a new machine needs only the one line in ~/.bashrc.
. "$HOME/dotfiles/profile"

# git
#alias gitsub="git submodule init && git submodule update --recursive"


# load a .env file (KEY=value) into the current shell and export all vars
function load_env() {
    local file="${1:-.env}"
    if [[ ! -f "$file" ]]; then
        echo "load_env: file not found: $file" >&2
        return 1
    fi
    set -a
    source "$file"
    set +a
    echo "load_env: loaded '$file'"
}


. "$HOME/dotfiles/aliases"
