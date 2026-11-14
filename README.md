# dotfiles

## Layout

| File | Content | Loaded by |
| --- | --- | --- |
| `bashrc` | Entry point: loads `profile`, defines functions, loads `aliases` | `~/.bashrc` |
| `profile` | Environment: `EDITOR`, `PATH` incl. `bin/` | `bashrc` |
| `aliases` | Aliases | `bashrc` |
| `bin/` | Scripts | `PATH` from `profile` |
| `gitconfig` | Git settings | `[include]` in `~/.gitconfig` |
| `.vimrc` | vim | symlink `~/.vimrc` |
| `.ipython/startup/` | IPython startup imports | symlink via `setup_ipython.sh` |
| `rofi-config.rasi` | rofi | symlink, see [Emoji picker](#emoji-picker-rofimoji) |

New scripts and changes arrive with a `git pull`; the setup below is needed once per machine.

## Setup

```sh
# ~/.bashrc
[ -f "$HOME/dotfiles/bashrc" ] && . "$HOME/dotfiles/bashrc"

# ~/.gitconfig
[include]
    path = ~/dotfiles/gitconfig

# vim, IPython
ln -s ~/dotfiles/.vimrc ~/.vimrc
~/dotfiles/setup_ipython.sh
```

## Scripts (`bin/`)

### Terminal reset (`fix-term`)
Repairs a terminal whose colour, underline or charset attribute got stuck.

```sh
fix-term --help
```

### Scan OCR (`pdfocr`)
Adds an invisible text layer to a scanned PDF, keeping the original (e.g. 600 dpi) images.

```sh
sudo pacman -S poppler qpdf tesseract tesseract-data-deu tesseract-data-eng
pdfocr --help
```

## Emoji picker (rofimoji)
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
