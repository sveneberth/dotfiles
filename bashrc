export EDITOR=vim

function ctx_bash() {
    local topic="${1:-}"
    if [[ -z "$topic" ]]; then
        echo "Usage: ctx_bash <topic>"
        local found=0
        for f in "$HOME"/.bash_history_ctx_*; do
            [[ -f "$f" ]] || continue
            (( found++ == 0 )) && echo "Available contexts:"
            echo "  ${f##*_ctx_}"
        done
        return 1
    fi
    local histfile="$HOME/.bash_history_ctx_$topic"
    echo "Entering bash context: $topic  ($histfile)"
    HISTFILE="$histfile" BASH_CTX="$topic" bash --rcfile <(printf '%s\n' \
        "source $HOME/.bashrc" \
        'PS1="\[\033[01;33m\](ctx:$BASH_CTX) \[\033[00m\]$PS1"' \
    )
}

# git
#alias gitsub="git submodule init && git submodule update --recursive"
function gac() {
    git commit -am "$1"
}
function gitDeleteLocalBranches() {
	git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D $branch; done
}


function randomStr() {
#    cat /dev/urandom | tr -cd ${2:-'a-zA-Z0-9'} | fold -w ${1:-8} | head -n 1
    tr -cd ${2:-'a-zA-Z0-9'} < /dev/urandom | head -c ${1:-8}
}


function releaseTag() {
    tag_name="release-`date +"%Y-%m-%d"`${1}"
    git tag -am "Release: ${2}" "$tag_name"
    git push "$(git remote)" "$tag_name"
}


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
