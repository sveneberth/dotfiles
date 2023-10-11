export EDITOR=vim

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
