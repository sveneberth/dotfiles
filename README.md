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

Where does a new helper go?
- changes the current shell (`cd`, `export`, prompt) → function in `bashrc`
- command with fixed options → `aliases`
- everything else → script in `bin/` (also works in Claude, `xargs`, other scripts)

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

### Backup copy (`bak`)
Copies files or directories to `<name>.bak-<timestamp>`, never overwriting an existing backup.

```sh
bak config.yaml some-dir/
```

### History context (`ctx_bash`)
Opens a nested bash with its own history file and the topic in the prompt. `exit` returns.

```sh
ctx_bash work    # history in ~/.bash_history_ctx_work
ctx_bash         # list the contexts
```

### Terminal reset (`fix-term`)
Repairs a terminal whose colour, underline or charset attribute got stuck.

```sh
fix-term --help
```

### Delete gone branches (`gitDeleteLocalBranches`)
Fetches with `--prune` and deletes local branches whose upstream is gone, unmerged ones too.

```sh
gitDeleteLocalBranches
git submodule foreach --recursive gitDeleteLocalBranches
```

### Scan OCR (`pdfocr`)
Adds an invisible text layer to a scanned PDF, keeping the original (e.g. 600 dpi) images.

```sh
sudo pacman -S poppler qpdf tesseract tesseract-data-deu tesseract-data-eng
pdfocr --help
```

### Random string (`randomStr`)
Prints a random string, by default 8 characters from `a-zA-Z0-9`.

```sh
randomStr 32 'a-f0-9'
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
