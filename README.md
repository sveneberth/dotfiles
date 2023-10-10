# dotfiles


### Load bash 
```sh
# load from dotfiles
if [ -f "$HOME/dotfiles/bashrc" ]; then 
    #echo "load $HOME/dotfiles/bashrc"
    . "$HOME/dotfiles/bashrc"
fi
if [ -f "$HOME/dotfiles/aliases" ]; then 
    #echo "load $HOME/dotfiles/aliases"
    . "$HOME/dotfiles/aliases"
fi
```

### Load git
```sh
[includeIf "gitdir:~/dotfiles/"]
    path = ~/dotfiles/gitconfig
```