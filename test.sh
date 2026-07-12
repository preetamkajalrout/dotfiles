#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0
WARN=0

pass() { ((PASS++)); printf "  [OK] %s\n" "$1"; }
fail() { ((FAIL++)); printf "  [FAIL] %s\n" "$1"; }
warn() { ((WARN++)); printf "  [WARN] %s\n" "$1"; }

check_cmd() {
  local cmd="$1"
  local label="${2:-$1}"
  if command -v "$cmd" &> /dev/null; then
    pass "$label is installed"
  else
    if [[ "$cmd" == "fd" ]] && command -v "fdfind" &> /dev/null; then
      pass "$label (fdfind) is installed"
    elif [[ "$cmd" == "bat" ]] && command -v "batcat" &> /dev/null; then
      pass "$label (batcat) is installed"
    else
      fail "$label is NOT installed"
    fi
  fi
}

check_symlink() {
  local link="$1"
  local expected_target="$2"
  if [[ -L "$link" ]]; then
    local actual_target
    actual_target="$(readlink "$link")"
    if [[ "$actual_target" == "$expected_target" ]]; then
      pass "Symlink OK: $link"
    else
      warn "Symlink exists but points to $actual_target"
    fi
  elif [[ -f "$link" ]]; then
    warn "$link exists but is a regular file, not a symlink"
  else
    fail "Symlink missing: $link"
  fi
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

echo "Dotfiles Environment Tests"
echo "--------------------------"

echo "Shell:"
if [[ "$SHELL" == *"zsh"* ]]; then pass "Default shell is zsh"; else fail "Default shell is NOT zsh"; fi

echo "Core Stack:"
check_cmd "git"
check_cmd "jq"
check_cmd "unzip"
check_cmd "nvim" "Neovim"
check_cmd "mise"

echo "Modern CLI Tools:"
check_cmd "gitui"
check_cmd "rg" "ripgrep"
check_cmd "fd" "fd-find"
check_cmd "bat"
check_cmd "fzf"
check_cmd "delta" "git-delta"

echo "Optional Tools:"
for cmd in kitty goku node python3 brew; do
  if command -v "$cmd" &> /dev/null; then pass "$cmd is installed"; else warn "$cmd is not installed"; fi
done

echo "Native Zsh Plugins & Theme:"
if [[ -d "$HOME/zsh-plugins/zsh-autosuggestions" ]]; then pass "zsh-autosuggestions installed"; else fail "zsh-autosuggestions NOT installed"; fi
if [[ -d "$HOME/powerlevel10k" ]]; then pass "powerlevel10k installed"; else fail "powerlevel10k NOT installed"; fi

echo "Dotfile Symlinks (Root):"
for src in $(find -H "$DOTFILES_DIR" -maxdepth 2 -name '*.symlink' -not -path '*.git*' 2>/dev/null); do
  base="$(basename "${src%.*}")"
  check_symlink "$HOME/.${base}" "$src"
done

echo "XDG Config Symlinks (~/.config):"
for src in "$DOTFILES_DIR"/config/*; do
  if [[ -d "$src" ]]; then
    base="$(basename "$src")"
    check_symlink "$HOME/.config/$base" "$src"
  fi
done

echo "Neovim Configuration:"
if [[ -f "$HOME/.config/nvim/init.lua" || -L "$HOME/.config/nvim" ]]; then pass "Neovim config exists"; else fail "Neovim config NOT found"; fi
if [[ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]]; then pass "lazy.nvim installed"; else warn "lazy.nvim not found"; fi

echo "Nerd Fonts:"
if [[ "$(uname)" == "Darwin" ]]; then
  if brew list --cask font-meslo-lg-nerd-font &> /dev/null 2>&1; then pass "Meslo Nerd Font installed"; elif [[ -n "$(find "$HOME/Library/Fonts" -name "*Meslo*" -print -quit 2>/dev/null)" ]]; then pass "Meslo Nerd Font found"; else fail "Meslo Nerd Font NOT found"; fi
else
  if [[ -n "$(find "$HOME/.local/share/fonts" -name "*Meslo*" -print -quit 2>/dev/null)" ]]; then pass "Meslo Nerd Font installed"; else fail "Meslo Nerd Font NOT found"; fi
fi

if [[ "$(uname)" == "Darwin" ]]; then
  echo "Brewfile Sync:"
  if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    local_check=$(brew bundle check --file="$DOTFILES_DIR/Brewfile" 2>&1 || true)
    if echo "$local_check" | grep -q "satisfied"; then pass "All Brewfile packages are installed"; else warn "Some Brewfile packages may be missing"; fi
  else
    fail "Brewfile not found at $DOTFILES_DIR/Brewfile"
  fi
fi

echo "--------------------------"
printf "Results: %d passed, %d failed, %d warnings\n" "$PASS" "$FAIL" "$WARN"

if [[ $FAIL -gt 0 ]]; then exit 1; fi