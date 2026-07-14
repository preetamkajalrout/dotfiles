#!/usr/bin/env bash
set -euo pipefail

# Utility Functions
info()    { printf "\r  [ .. ] %s\n" "$1"; }
user()    { printf "\r  [ ?? ] %s\n" "$1"; }
success() { printf "\r\033[2K  [ OK ] %s\n" "$1"; }
fail()    { printf "\r\033[2K  [FAIL] %s\n" "$1"; exit 1; }

# Global Variables
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PLATFORM=""
DRY_RUN="${DRY_RUN:-false}"

# Platform Detection
determine_platform() {
  if [[ "$(uname)" == "Darwin" ]]; then
    PLATFORM="mac"
  else
    PLATFORM="linux"
  fi
  info "Platform detected: $PLATFORM"
}

is_available() {
  local cmd="${1:-}"
  local path_check="${2:-}"

  if [[ -n "$path_check" ]]; then
    [[ -d "$path_check" || -f "$path_check" ]]
    return $?
  fi

  if command -v "$cmd" &> /dev/null; then
    return 0
  fi
  return 1
}


setup_brew() {
  if is_available "brew"; then
    success "brew: available"
  else
    info "brew: installing..."
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[DRY RUN] Install Homebrew"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "brew: installed"
  fi
}

setup_brew_packages() {
  info "Installing packages from Brewfile..."
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[DRY RUN] brew bundle --file=$DOTFILES_DIR/Brewfile"
  else
    brew bundle --file="$DOTFILES_DIR/Brewfile"
  fi
  success "Brewfile packages installed"
}

setup_linux_packages() {
  info "Installing Linux packages from Aptfile..."
  
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[DRY RUN] apt install -y (packages from Aptfile)"
  else
    sudo apt update
    # Read Aptfile, remove comments and empty lines, pass to apt install
    grep -vE "^\s*#" "$DOTFILES_DIR/Aptfile" | grep -vE "^\s*$" | xargs sudo apt install -y
    success "Aptfile packages installed"
  fi


  if ! is_available "mise"; then
    info "mise: installing..."
    if [[ "$DRY_RUN" != "true" ]]; then
      curl https://mise.run | sh
    fi
    success "mise: installed"
  else
    success "mise: available"
  fi
}

setup_linux_nerdfonts() {
  info "nerd-fonts: checking..."
  local nf_version
  nf_version="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')"
  local font_names=("CascadiaCode" "Hack" "Meslo" "Agave")
  local usr_font_dir="$HOME/.local/share/fonts/NerdFonts"
  mkdir -p "$usr_font_dir"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  for font in "${font_names[@]}"; do
    if [[ -n "$(find "$usr_font_dir" -name "*${font}*" -print -quit 2>/dev/null)" ]]; then
      success "nerd-fonts: ${font} already installed"
    else
      info "nerd-fonts: downloading ${font}..."
      if [[ "$DRY_RUN" != "true" ]]; then
        curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/${nf_version}/${font}.zip" -o "${tmp_dir}/${font}.zip"
        unzip -qo "${tmp_dir}/${font}.zip" -d "${tmp_dir}/${font}"
        find "${tmp_dir}/${font}" -type f \( -name "*.ttf" -o -name "*.otf" \) ! -name "*Windows*" -exec cp {} "$usr_font_dir" \;
      fi
      success "nerd-fonts: ${font} installed"
    fi
  done

  rm -rf "$tmp_dir"
  fc-cache -fv "$usr_font_dir" > /dev/null 2>&1 || true
}

backup_bash_configs() {
  info "Backing up bash config files..."
  local backup_dir="$HOME/.bash_backup_$(date +%Y%m%d_%H%M%S)"
  local backed_up=false

  for f in "$HOME/.bashrc" "$HOME/.bash_history" "$HOME/.bash_aliases"; do
    if [[ -f "$f" ]]; then
      if [[ "$backed_up" == "false" ]]; then
        mkdir -p "$backup_dir"
        backed_up=true
      fi
      mv "$f" "$backup_dir/"
      info "  Backed up $(basename "$f") -> $backup_dir/"
    fi
  done

  if [[ "$backed_up" == "true" ]]; then
    success "Bash configs backed up to $backup_dir"
  else
    success "No bash configs to back up"
  fi
}

setup_zsh() {
  info "Checking zsh..."
  if [[ "$SHELL" == *"zsh"* ]]; then
    success "zsh: already default shell"
  else
    info "zsh: setting as default shell..."
    if [[ "$DRY_RUN" != "true" ]]; then
      chsh -s "$(command -v zsh)"
    fi
    success "zsh: set as default shell"
  fi
  backup_bash_configs
}

setup_zsh_plugins() {
  info "zsh-plugins: checking..."
  local plugins_dir="$HOME/zsh-plugins"
  local plugin_name="zsh-autosuggestions"
  local plugin_repo="https://github.com/zsh-users/zsh-autosuggestions"

  mkdir -p "$plugins_dir"

  if [[ -d "$plugins_dir/$plugin_name" ]]; then
    success "zsh-plugins: ${plugin_name} already installed"
  else
    info "zsh-plugins: ${plugin_name} installing..."
    if [[ "$DRY_RUN" != "true" ]]; then
      git clone "$plugin_repo" "$plugins_dir/$plugin_name"
    fi
    success "zsh-plugins: ${plugin_name} installed"
  fi
}

setup_p10k() {
  local p10k_dir="$HOME/powerlevel10k"
  if [[ -d "$p10k_dir" ]]; then
    success "powerlevel10k: already installed"
  else
    info "powerlevel10k: installing..."
    if [[ "$DRY_RUN" != "true" ]]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi
    success "powerlevel10k: installed"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"

  if [[ -f "$dst" || -d "$dst" || -L "$dst" ]]; then
    local current_src
    current_src="$(readlink "$dst" 2>/dev/null || echo "")"
    if [[ "$current_src" == "$src" ]]; then
      success "skipped $src (already linked)"
      return
    fi

    mv "$dst" "${dst}.backup"
    success "backed up $dst -> ${dst}.backup"
  fi

  ln -s "$src" "$dst"
  success "linked $src -> $dst"
}

install_dotfiles() {
  info "Installing dotfiles..."
  # 1. Root dotfiles (like zshrc, aliases)
  for src in $(find -H "$DOTFILES_DIR" -maxdepth 2 -name '*.symlink' -not -path '*.git*'); do
    local base="$(basename "${src%.*}")"
    local dst="$HOME/.${base}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[DRY RUN] link $src -> $dst"
    else
      link_file "$src" "$dst"
    fi
  done

  # 2. XDG Configuration files (like nvim, kitty)
  mkdir -p "$HOME/.config"
  for src in "$DOTFILES_DIR"/config/*; do
    if [[ -d "$src" ]]; then
      base="$(basename "$src")"
      
      # Skip kitty, handled explicitly below to avoid git pollution
      if [[ "$base" == "kitty" ]]; then
        continue
      fi

      dst="$HOME/.config/$base"
      
      if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] link $src -> $dst"
      else
        link_file "$src" "$dst"
      fi
    fi
  done

  # 3. Explicit File Links (to prevent polluting the dotfiles repo with auto-generated state)
  info "Linking explicit config files..."
  mkdir -p "$HOME/.config/kitty"
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[DRY RUN] link $DOTFILES_DIR/config/kitty/kitty.conf.symlink -> $HOME/.config/kitty/kitty.conf"
  else
    link_file "$DOTFILES_DIR/config/kitty/kitty.conf.symlink" "$HOME/.config/kitty/kitty.conf"
  fi
}

setup_kitty_themes() {
  info "kitty-themes: installing One Dark..."
  mkdir -p "$HOME/.config/kitty"
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[DRY RUN] Download One Dark themes to ~/.config/kitty using kitten themes"
  else
    if command -v kitten &> /dev/null; then
      kitten themes --dump-theme "One Dark" > "$HOME/.config/kitty/dark-theme.auto.conf"
      kitten themes --dump-theme "Atom One Light" > "$HOME/.config/kitty/light-theme.auto.conf"
      kitten themes --dump-theme "One Dark" > "$HOME/.config/kitty/no-preference-theme.auto.conf"
    else
      info "kitty: not installed, skipping theme generation"
    fi
  fi
  success "themes: installed"
}

setup_rust() {
  info "rustup: checking..."
  if is_available "rustup" "$HOME/.cargo/bin/rustup"; then
    success "rustup: already installed"
  else
    info "rustup: installing..."
    if [[ "$DRY_RUN" != "true" ]]; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    fi
    success "rustup: installed"
  fi
}

main() {
  determine_platform

  if [[ "$PLATFORM" == "mac" ]]; then
    setup_brew
    setup_brew_packages
  else
    setup_linux_packages
    setup_linux_nerdfonts
  fi

  setup_rust
  setup_zsh
  setup_zsh_plugins
  setup_p10k
  install_dotfiles
  setup_kitty_themes

  echo ""
  info "Installing global tools via mise..."
  
  # Ensure ~/.local/bin is in PATH for a fresh Linux install
  export PATH="$HOME/.local/bin:$PATH"
  
  if [[ "$DRY_RUN" != "true" ]]; then
    mise install -y || info "mise: some tools may have failed"
  fi

  # Run goku after dotfiles are linked so Karabiner sees the updated EDN
  if [[ "$PLATFORM" == "mac" ]] && is_available "goku"; then
    info "goku: compiling karabiner.edn..."
    if [[ "$DRY_RUN" != "true" ]]; then
      goku || info "goku: note - Karabiner-Elements might not be running yet."
    fi
  fi

  echo ""
  success "Setup complete! Open a new terminal (or run 'exec zsh')."
}

help() {
  cat <<EOF

  Usage: ./setup.sh [options]

  Setup script for macOS / Linux environment.
  Installs tooling, fonts, and symlinks dotfiles.

  Options:
    help       Prints this help info
    main       Runs the full setup (tooling + fonts + dotfiles)
    --dry-run  Previews what would be installed without making changes

EOF
}

CMD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN="true"
      info "DRY RUN MODE - no changes will be made"
      shift
      ;;
    help)
      help
      exit 0
      ;;
    main)
      CMD="main"
      shift
      ;;
    *)
      help
      exit 1
      ;;
  esac
done

if [[ "$CMD" == "main" ]]; then
  main
else
  help
fi
