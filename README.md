# dotfiles

## Layout

| File | Content | Loaded by |
| --- | --- | --- |
| `bashrc` | Entry point: loads `profile`, defines functions, loads `aliases` | `~/.bashrc` |
| `profile` | Environment: `EDITOR`, `PATH` incl. `bin/` | `bashrc` |
| `aliases` | Aliases | `bashrc` |
| `bin/` | Scripts | `PATH` from `profile` |
| `gitconfig` | Git settings | `[include]` in `~/.gitconfig` |
| `.vimrc` | vim | symlink `~/.vimrc` (and `/root/.vimrc` with `--root`) |
| `.ipython/startup/` | IPython startup imports | symlink `~/.ipython/profile_default/startup`, if IPython is installed |
| `rofi-config.rasi` | rofi | symlink `~/.config/rofi/config.rasi`, if rofi is installed |

## Setup

```sh
git clone git@github.com:sveneberth/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh            # --root: also link the vimrc for sudo vim
```

`--root` only on single-user machines: `/root/.vimrc` applies to everyone who becomes root.
On shared servers use `sudoedit <file>`, which runs vim as you with your vimrc.

`setup.sh` adds the load lines to `~/.bashrc` and `~/.gitconfig` and creates the symlinks.
Safe to run again: existing setup is reported as `ok`. A file in the way with different
content shows its diff and asks to overwrite, back up or skip.

New scripts and changes arrive with a `git pull`. Run `setup.sh` again only when a new
symlink was added.

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
# Install, then link the config
yay -S rofi rofimoji
~/dotfiles/setup.sh

# Add shortcut in XFCE: Settings > Keyboard > Application Shortcuts
# - Command: rofimoji
# - Shortcut: [Ctrl]+.
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary>period" -n -t string -s "rofimoji"
```
