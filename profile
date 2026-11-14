# Environment (`PATH`, `EDITOR`), loaded from bashrc.
# Aliases, functions and prompt settings belong in bashrc itself.

export EDITOR=vim

case ":${PATH}:" in
    *:"$HOME/dotfiles/bin":*) ;;
    *) export PATH="$PATH:$HOME/dotfiles/bin" ;;
esac
