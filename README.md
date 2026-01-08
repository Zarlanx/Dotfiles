# dotfiles

Personal dotfiles managed as a simple repo. Files live under `home/` mirroring `$HOME`.

## Contents
- Shell: `home/.bashrc`, `.bash_profile`, `.profile`
- Tmux: `home/.tmux.conf.local` (Oh My Tmux overrides)
- Terminal: `home/.config/ghostty/config`, `home/.config/kitty/kitty.conf`, `home/.config/alacritty/alacritty.toml`
- Hyprland: `home/.config/hypr/*` (Hyprland, hypridle, hyprlock, etc.)
- Waybar: `home/.config/waybar/{config.jsonc,style.css}`
- Notifications: `home/.config/mako` (if present)
- LazyVim: `home/.config/nvim/*` (LazyVim starter, lockfile)
- Omarchy branding: `home/.config/omarchy/*`
- Arch package lists: `arch/explicit-packages.txt`, `arch/aur-packages.txt`
- Extras: `extras/xterm-ghostty.terminfo` (install on remotes with `tic -x -o ~/.terminfo xterm-ghostty.terminfo`)

## Usage
- Inspect then copy or symlink as you prefer:
  - Copy: `cp -r home/. ~`
  - Symlink (example):
    - `ln -snf "$PWD/home/.bashrc" ~/.bashrc`
    - `ln -snf "$PWD/home/.tmux.conf.local" ~/.tmux.conf.local`
    - `mkdir -p ~/.config/ghostty && ln -snf "$PWD/home/.config/ghostty/config" ~/.config/ghostty/config`
    - `mkdir -p ~/.config/hypr && ln -snf "$PWD/home/.config/hypr"/* ~/.config/hypr/`
    - `mkdir -p ~/.config/waybar && ln -snf "$PWD/home/.config/waybar"/* ~/.config/waybar/`
    - `mkdir -p ~/.config/nvim && ln -snf "$PWD/home/.config/nvim"/* ~/.config/nvim/`

## Oh My Tmux
This repo does not vendor the upstream `~/.tmux` directory. Install/update with:
```sh
git clone https://github.com/gpakosz/.tmux.git ~/.tmux || (cd ~/.tmux && git pull --ff-only)
ln -snf ~/.tmux/.tmux.conf ~/.tmux.conf
```
Then reload in tmux: `tmux source-file ~/.tmux.conf`.

## Hyprland & Waybar
Configs live under `home/.config/hypr` and `home/.config/waybar`.
- Hyprland main config: `hyprland.conf` with includes for `monitors.conf`, `bindings.conf`, etc.
- Waybar loads `config.jsonc` and `style.css` (references `~/.config/omarchy/current/theme/waybar.css` if present).

Reload:
```
hyprctl reload
pkill -SIGUSR2 waybar || waybar &
```

## LazyVim (Neovim)
The `home/.config/nvim` folder is a LazyVim starter with `lazy-lock.json` pinned versions.
- First launch installs plugins: `nvim`.
- Update plugins: `:Lazy sync`.

## Ghostty terminfo
If remotes lack `xterm-ghostty`, upload and install:
```sh
scp extras/xterm-ghostty.terminfo user@host:~/
ssh user@host 'tic -x -o ~/.terminfo ~/xterm-ghostty.terminfo'
```
