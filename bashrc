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


# create timestamped backup copies of files or directories (recursively)
function bak() {
    if (( $# == 0 )); then
        echo "Usage: bak <path>..." >&2
        return 1
    fi
    local stamp
    stamp="$(date +"%Y-%m-%d_%H-%M")"
    local src dest n rc=0
    for src in "$@"; do
        # strip trailing slashes, else `cp -a dir/ dir.bak` copies into an existing target
        while [[ "$src" == */ && "$src" != "/" ]]; do
            src="${src%/}"
        done
        if [[ ! -e "$src" && ! -L "$src" ]]; then
            echo "bak: not found: $src" >&2
            rc=1
            continue
        fi
        dest="$src.bak-$stamp"
        n=2
        # never clobber an existing backup, count up instead
        while [[ -e "$dest" || -L "$dest" ]]; do
            dest="$src.bak-$stamp.$((n++))"
        done
        if cp -a -- "$src" "$dest"; then
            echo "$src -> $dest"
        else
            rc=1
        fi
    done
    return $rc
}


# log-with-tee: run a command and mirror its output (stdout+stderr) into a log file
# named after the script or command being run:
#   lwt ./cleanup_task.py --fix          -> ./cleanup_task_2026-09-09-08-30.log
#   lwt -d : pr viur run develop -w 4    -> ./viur_run_develop_2026-09-09.log
# Options go before the command, `:` (or `--`) divides them from it; without options
# the divider can be left out. Options:
#   -n NAME  log name (default: derived)   -d  daily stamp (%Y-%m-%d)
#   -t FMT   date(1) format                -N  no timestamp at all
#   -D DIR   log directory                 -x  truncate instead of append
# As a pipe it consumes stdin instead of running anything - then the log name has to
# come from -n (default: log):
#   pr ./cleanup_task.py --fix |& lwt -n cleanup_task
# Defaults can also come from LWT_LOG_DIR and LWT_TIMESTAMP; options win.
# Returns the exit code of the command, not the one of tee.
lwt() {
    local usage="Usage: lwt [-n NAME] [-t FMT|-d|-N] [-D DIR] [-x] [:] <command> [args...]"
    local name="" stamp_fmt="${LWT_TIMESTAMP-%Y-%m-%d-%H-%M}" dir="${LWT_LOG_DIR-}" append=1

    while (( $# )); do
        case "$1" in
            -n|-t|-D)
                if (( $# < 2 )); then
                    echo "lwt: option $1 needs an argument" >&2
                    return 1
                fi
                case "$1" in
                    -n) name="$2" ;;
                    -t) stamp_fmt="$2" ;;
                    -D) dir="$2" ;;
                esac
                shift 2 ;;
            -d) stamp_fmt="%Y-%m-%d"; shift ;;
            -N) stamp_fmt=""; shift ;;
            -x) append=0; shift ;;
            -h|--help) echo "$usage" >&2; return 0 ;;
            :|--) shift; break ;;
            *) break ;;
        esac
    done

    # pipe mode: `cmd |& lwt -n name` - no command, output arrives on stdin
    local from_stdin=0
    if (( $# == 0 )); then
        if [[ -t 0 ]]; then
            echo "$usage" >&2
            return 1
        fi
        from_stdin=1
        name="${name:-log}"
    fi

    # bash alias-expands only the word right after `lwt`, so behind an option a
    # wrapper like `pr` arrives unexpanded - and `pr` is also /usr/bin/pr. Resolve it.
    local adef awords
    if (( ! from_stdin )) && adef=$(alias -- "$1" 2>/dev/null); then
        adef=${adef#*=\'}
        adef=${adef%\'}
        if eval "awords=($adef)" 2>/dev/null && (( ${#awords[@]} )); then
            shift
            set -- "${awords[@]}" "$@"
        fi
    fi

    if [[ -z "$name" ]]; then
        # words that only wrap the actual command and must not name the log file
        local wrapper_re='^(pipenv|poetry|uv|pdm|hatch|rye|run|sudo|env|time|nohup|command|python|python3)$'
        local arg base words=()

        # 1) a script path among the arguments names the log
        for arg in "$@"; do
            [[ "$arg" == -* ]] && continue
            [[ "$arg" == */* || "$arg" == *.py || "$arg" == *.sh ]] || continue
            [[ -f "$arg" ]] || continue
            base="${arg##*/}"
            name="${base%.*}"
            break
        done

        # 2) otherwise the command plus its sub-commands, up to the first option
        if [[ -z "$name" ]]; then
            for arg in "$@"; do
                [[ "$arg" == -* ]] && break
                # skip wrappers only while they still lead the command
                (( ${#words[@]} == 0 )) && [[ "$arg" =~ $wrapper_re ]] && continue
                base="${arg##*/}"
                words+=("${base%.*}")
                (( ${#words[@]} == 3 )) && break
            done
            name="$(IFS=_; echo "${words[*]}")"
        fi
        [[ -n "$name" ]] || name="${1##*/}"
    fi
    name="${name//[^a-zA-Z0-9._-]/_}"

    local stamp=""
    [[ -n "$stamp_fmt" ]] && stamp="_$(date +"$stamp_fmt")"
    local log="${dir:+${dir%/}/}${name}${stamp}.log"

    echo "lwt: logging to ${log}" >&2
    (( append )) || : > "$log"

    if (( from_stdin )); then
        # the command's exit code stays with the caller: ${PIPESTATUS[0]} over there
        printf '=== lwt: <stdin> | %s ===\n' "$(date +'%Y-%m-%d %H:%M:%S')" >> "$log"
        tee -a -- "$log"
        return $?
    fi

    printf '=== lwt: %s | %s ===\n' "$*" "$(date +'%Y-%m-%d %H:%M:%S')" >> "$log"
    "$@" |& tee -a -- "$log"
    return "${PIPESTATUS[0]}"
}
# The trailing blank makes bash alias-expand the word right after `lwt`, which covers
# `lwt pr ...`; behind an option the function resolves the alias itself.
alias lwt='lwt '
