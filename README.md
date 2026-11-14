# dotfiles


### Load bash
One line in `~/.bashrc`. `bashrc` pulls in `profile` (`PATH` incl. `bin/`, `EDITOR`) and `aliases` itself.

```sh
[ -f "$HOME/dotfiles/bashrc" ] && . "$HOME/dotfiles/bashrc"
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

### Scripts (`bin/`)
On the `PATH` via `profile`, so new scripts are available after a `git pull`.

#### Terminal reset (`fix-term`)
Repairs a terminal whose colour, underline or charset attribute got stuck.

```sh
fix-term --help
```

#### Scan OCR (`pdfocr`)
Adds an invisible text layer to a scanned PDF, keeping the original (e.g. 600 dpi) images.

```sh
sudo pacman -S poppler qpdf tesseract tesseract-data-deu tesseract-data-eng
pdfocr --help
```

### Load git
```sh
[include]
    path = ~/dotfiles/gitconfig
```
