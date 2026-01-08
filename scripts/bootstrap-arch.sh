#!/usr/bin/env bash
set -euo pipefail

# Arch Linux bootstrap for this dotfiles repo.
# - Installs core packages (pacman)
# - Optionally installs AUR packages via paru
# - Symlinks files from repo/home into $HOME
# - Installs Oh My Tmux and Ghostty terminfo
#
# Usage:
#   ./scripts/bootstrap-arch.sh [--link-only] [--no-aur] [--no-pkgs] [--dry-run]
#
# Defaults: installs packages (pacman), attempts AUR via paru, and links files.

DRY_RUN=0
INSTALL_PKGS=1
INSTALL_AUR=1
LINK_FILES=1

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --link-only) INSTALL_PKGS=0; INSTALL_AUR=0; LINK_FILES=1 ;;
    --no-aur) INSTALL_AUR=0 ;;
    --no-pkgs) INSTALL_PKGS=0 ;;
    *) echo "Unknown arg: $arg"; exit 2 ;;
  esac
done

say() { printf "\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[err]\033[0m %s\n" "$*"; }

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DOTFILES_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

if ! command -v pacman >/dev/null 2>&1; then
  warn "pacman not found. This script targets Arch-based systems."
  warn "Proceeding to link files only. Use --link-only to silence this."
  INSTALL_PKGS=0
  INSTALL_AUR=0
fi

# sudo helper
SUDO=""
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then SUDO=sudo; else warn "sudo not available; attempting without"; fi
fi

run() {
  if [ "$DRY_RUN" -eq 1 ]; then echo "DRY_RUN: $*"; else eval "$*"; fi
}

pkg_available() { pacman -Si "$1" >/dev/null 2>&1; }
pkg_installed() { pacman -Qi "$1" >/dev/null 2>&1; }

pacman_install_supported() {
  local pkg to_install=()
  for pkg in "$@"; do
    if pkg_available "$pkg"; then
      if ! pkg_installed "$pkg"; then to_install+=("$pkg"); fi
    else
      warn "Not in official repos (skipping for pacman): $pkg"
    fi
  done
  if [ ${#to_install[@]} -gt 0 ]; then
    say "Installing with pacman: ${to_install[*]}"
    run "$SUDO pacman -S --noconfirm --needed ${to_install[*]}"
  else
    say "No new pacman packages needed."
  fi
}

ensure_paru() {
  if ! command -v paru >/dev/null 2>&1; then
    if [ "$INSTALL_AUR" -eq 0 ]; then return 0; fi
    say "Installing paru (AUR helper)"
    # Ensure base-devel and git are present for makepkg
    pacman_install_supported base-devel git
    local tmpdir
    tmpdir=$(mktemp -d)
    ( cd "$tmpdir" && run "git clone https://aur.archlinux.org/paru-bin.git" && cd paru-bin && run "makepkg -si --noconfirm" )
    rm -rf "$tmpdir"
  fi
}

aur_install_if_missing() {
  local pkg missing=()
  for pkg in "$@"; do
    if ! pkg_installed "$pkg"; then missing+=("$pkg"); fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    ensure_paru
    if command -v paru >/dev/null 2>&1; then
      say "Installing via AUR (paru): ${missing[*]}"
      run "paru -S --noconfirm --needed ${missing[*]}"
    else
      warn "paru not available; cannot install AUR packages: ${missing[*]}"
    fi
  fi
}

install_packages() {
  say "Installing core packages"
  pacman_install_supported \
    git curl wget tmux neovim ripgrep fd fzf unzip zip tar util-linux \
    python python-pip nodejs npm gcc base-devel

  say "Installing terminal & Wayland stack"
  pacman_install_supported kitty alacritty wl-clipboard waybar hyprland mako grim slurp wofi

  # Hypr components sometimes live in AUR
  aur_install_if_missing hypridle hyprlock hyprpaper hyprsunset || true

  # Fonts (AUR): Cascadia Code Nerd Font for your Kitty/Ghostty config
  aur_install_if_missing nerd-fonts-cascadia-code ttf-cascadia-code-nerd || true
}

link_dotfiles() {
  say "Linking dotfiles from $DOTFILES_DIR/home into $HOME"
  local src root rel dst ts
  root="$DOTFILES_DIR/home"
  ts=$(date +%Y%m%d-%H%M%S)
  # Link every file; ensure parent dirs exist
  while IFS= read -r -d '' src; do
    rel=${src#"$root/"}
    dst="$HOME/$rel"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      warn "Backing up existing: $dst -> $dst.bak.$ts"
      run "mv \"$dst\" \"$dst.bak.$ts\""
    fi
    run "ln -snf \"$src\" \"$dst\""
  done < <(find "$root" -type f -print0)
}

install_oh_my_tmux() {
  say "Setting up Oh My Tmux"
  if [ ! -d "$HOME/.tmux/.git" ]; then
    run "git clone --depth 1 https://github.com/gpakosz/.tmux.git \"$HOME/.tmux\""
  else
    run "git -C \"$HOME/.tmux\" pull --ff-only"
  fi
  run "ln -snf \"$HOME/.tmux/.tmux.conf\" \"$HOME/.tmux.conf\""
  # Ensure local override is linked by link_dotfiles step; create if missing
  if [ ! -f "$HOME/.tmux.conf.local" ] && [ -f "$DOTFILES_DIR/home/.tmux.conf.local" ]; then
    run "ln -snf \"$DOTFILES_DIR/home/.tmux.conf.local\" \"$HOME/.tmux.conf.local\""
  fi
}

install_ghostty_terminfo() {
  local terminfo_src="$DOTFILES_DIR/extras/xterm-ghostty.terminfo"
  if [ -f "$terminfo_src" ]; then
    say "Installing Ghostty terminfo to ~/.terminfo"
    mkdir -p "$HOME/.terminfo"
    run "tic -x -o \"$HOME/.terminfo\" \"$terminfo_src\""
  else
    warn "extras/xterm-ghostty.terminfo not found; skipping"
  fi
}

main() {
  if [ "$INSTALL_PKGS" -eq 1 ]; then install_packages; fi
  if [ "$LINK_FILES" -eq 1 ]; then link_dotfiles; fi
  install_oh_my_tmux
  install_ghostty_terminfo

  say "Bootstrap complete. Next steps:"
  echo "- Start tmux: tmux new -A -s main"
  echo "- Launch Hyprland session; reload: hyprctl reload"
  echo "- Start Waybar: waybar & (or your Hyprland autostart)"
  echo "- First run of Neovim will install plugins"
}

main "$@"

