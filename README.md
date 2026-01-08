# dotfiles

Personal dotfiles managed as a simple repo. Files live under `home/` mirroring `$HOME`.

## Contents
- `home/.bashrc`, `.bash_profile`, `.profile`
- `home/.tmux.conf.local` (Oh My Tmux overrides)
- `home/.config/ghostty/config`
- `extras/xterm-ghostty.terminfo` (install on remotes with `tic -x -o ~/.terminfo xterm-ghostty.terminfo`)

## Usage
- Inspect then copy or symlink as you prefer:
  - Copy: `cp -r home/. ~`
  - Symlink (example):
    - `ln -snf "$PWD/home/.bashrc" ~/.bashrc`
    - `ln -snf "$PWD/home/.tmux.conf.local" ~/.tmux.conf.local`
    - `mkdir -p ~/.config/ghostty && ln -snf "$PWD/home/.config/ghostty/config" ~/.config/ghostty/config`

## Oh My Tmux
This repo does not vendor the upstream `~/.tmux` directory. Install/update with:
```sh
git clone https://github.com/gpakosz/.tmux.git ~/.tmux || (cd ~/.tmux && git pull --ff-only)
ln -snf ~/.tmux/.tmux.conf ~/.tmux.conf
```
Then reload in tmux: `tmux source-file ~/.tmux.conf`.

## Ghostty terminfo
If remotes lack `xterm-ghostty`, upload and install:
```sh
scp extras/xterm-ghostty.terminfo user@host:~/
ssh user@host 'tic -x -o ~/.terminfo ~/xterm-ghostty.terminfo'
```
