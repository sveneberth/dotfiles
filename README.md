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

### Emoji picker (rofimoji)
```sh
# Install
yay -S rofi rofimoji

# Symlink rofi config
mkdir -p ~/.config/rofi
ln -s ~/dotfiles/rofi-config.rasi ~/.config/rofi/config.rasi

# Add shortcut in XFCE: Settings > Keyboard > Application Shortcuts
# - Command: rofimoji
# - Shortcut: [Ctrl]+.
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary>period" -n -t string -s "rofimoji"
```

### Load git
```sh
[include]
    path = ~/dotfiles/gitconfig
```
