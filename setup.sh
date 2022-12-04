#!/usr/bin/env bash

# Utility methods
info() {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user() {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success() {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail() {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

# Global variables
success_icon="✅ "
error_icon="⛔️ "

platform='mac' # Possible values: mac, wsl2
determine_platform() {
  if [[ $(uname) == "Darwin" ]]; then
    platform="mac"
    sys_font_dir="/Library/Fonts"
    usr_font_dir="$HOME/Library/Fonts"
  else
    platform="wsl2"
    sys_font_dir="/usr/local/share/fonts"
    usr_font_dir="$HOME/.local/share/fonts"
  fi
  sys_font_dir="${sys_font_dir}/NerdFonts"
  usr_font_dir="${usr_font_dir}/NerdFonts"
}

# checks if the command is available on running shell
# command_code          {string} command as-is run in the shell
# absolute_check_param  {string} absolute path file/directory (based on context) to be checked
# returns {boolean}     0=off, 1=on
check_command() {
  local command_code=$1
  local absolute_check_param=$2
  local is_found=0
  if [[ -z $absolute_check_param ]]; then
    if ! command -v $command_code &> /dev/null; then
      # Not found via. built-in command
      out="$(type ${command_code})"
      if [[ $out == *"not found"* || -z $out ]]; then
        # Not found via. type
        is_found=0
      else
        # Found via. type
        is_found=1
      fi
    else
      # Found via. built-in command
      is_found=1
    fi
  elif [[ -d $absolute_check_param || -f $absolute_check_param ]]; then
    # Found via. directory/path check
    is_found=1
  fi
  return $is_found
}

install_deb_pkg() {
  local pkg_nvim_src=("nvim-linux64.deb" "neovim" "neovim")
  local name=$1
  local pkg_name_src="pkg_${name}_src"
  local pkg_name="${!pkg_name_src}[0]"
  local deb_pkg_repo_owner="${!pkg_name_src}[1]"
  local deb_pkg_repo="${!pkg_name_src}[2]"
  get_stable_rel "${deb_pkg_repo_owner}" "${deb_pkg_repo}"
  local deb_download_url="https://github.com/${deb_pkg_repo_owner}/${deb_pkg_repo}/releases/download/${stable_rel}/${pkg_name}"
  info "$pkg_name: installing ..."
  sleep 10
  curl -L "$deb_download_url" --output "$pkg_dl_dir/${pkg_name}"
  sudo apt install -y "$pkg_dl_dir/${pkg_name}"
  success "$pkg_name: success $success_icon"
}

install_apt_pkg() {
  local pkg_git="git"
  local pkg_jq="jq"
  local pkg_unzip="unzip"
  local pkg_nvim="neovim"
  local pkg_name="pkg_$name"
  local name=$1
  if [[ ${!pkg_name} == "nvim" ]]; then
    install_deb_pkg "nvim"
  else
    info "${name}: Installation started..."
    sudo apt install -y "${!pkg_name}"
    success "${name}: Installation completed!"
  fi
}

install_brew_pkg() {
  pkg_git="git"
  pkg_jq="jq"
  pkg_unzip="unzip"
  pkg_nvim="neovim"
  pkg_name="pkg_$name"
  name=$1
  info "${name}: Installation started..."
  brew install "${!pkg_name}"
  success "${name}: Installation completed!"
}

install_git_pkg() { # params: repo owner, repo name, target directory, depth, tagname
  git_repo_owner=$1
  git_repo_name=$2
  git_clone_target=$3
  git_clone_depth=$4
  git_clone_tag=$5
  github_clone_url="https://github.com/${git_repo_owner}/${git_repo_name}.git"
  git_query="$github_clone_url $git_clone_target"
  if [ -n "$git_clone_depth" ]; then
    git_query="--depth=${git_clone_depth} "$git_query
  fi
  if [ -n "$git_clone_tag" ]; then
    git_query=$git_query" --branch ${git_clone_tag}"
  fi
  sleep 10
  echo "$git_query"
  info "Clone the ${git_repo_owner}/${git_repo_name} to ${git_clone_target}, Extra params: tag=${git_clone_tag}, depth=${git_clone_depth}"
  git clone $git_query
  success "Cloning ${git_repo_owner}/${git_repo_name} completed! $success_icon"
}

install_for_platform() {
  # param: tool/package name
  case $platform in
    mac)
      install_brew_pkg $1
      ;;
    wsl2)
      install_apt_pkg $1
      ;;
    *)
      echo "Platform is not decided"
      ;;
  esac
}

setup_pkg() { # params: command as used in shells
  command_code=$1
  check_command "$command_code"
  is_command_available=$?
  if [[ $is_command_available == 0 ]]; then
    # install the pkg
    install_for_platform "$command_code"
  else
    success "${command_code}: available $success_icon"
  fi
}

# depends on jq
get_stable_rel() { #params: owner of repo, repo name
  repo_owner=$1
  repo_name=$2
  stable_rel="$(curl https://api.github.com/repos/${repo_owner}/${repo_name}/releases | jq -r 'map(select(.prerelease == false))[0].tag_name')"
}

# setups the platform specific directory and script root directories
setup_scriptenv() {
  determine_platform
  dotfiles_dir="$HOME/dotfiles"
  download_dir="${dotfiles_dir}/.tmp/downloads"
  fonts_dl_dir=${download_dir}"/fonts"
  pkg_dl_dir=${download_dir}"/pkg"
  mkdir -p "$fonts_dl_dir"
  mkdir -p "$pkg_dl_dir"
}

rm_scriptdirs() {
  info "removing $HOME/.tmp directory"
  rm -r "${dotfiles_dir}/.tmp"
  success "$HOME/.tmp directory cleaned up"
}

setup_git() {
  # for mac it shouldn't be needed.
  setup_pkg "git"
}

setup_brew() {
  check_command brew
  is_brew_available=$?
  if [[ is_brew_available == 0 ]]; then
    # install brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    info "brew: available"
  fi
}

setup_unzip() {
  setup_pkg "unzip"
}

setup_jq() {
  setup_pkg "jq"
}

# depends on unzip
install_font() { # params: font-name
  font=$1
  # download the zip file for the font, unzip to directory & copy to user font directory
  if [ ! -f "${fonts_dl_dir}/${font}.zip" ]; then
    curl -L "${nf_base_dl_url}/${font}.zip" --output "${fonts_dl_dir}/${font}.zip"
  fi
  unzip -o "${fonts_dl_dir}/${font}.zip" -d "${fonts_dl_dir}/${font}"
  # copy the fonts to usr_font_dir
  if [[ -z $(find "${fonts_dl_dir}/${font}" -type f -name "*.otf*" \! -name "*Windows Compatible*") ]]; then
    font_ext="ttf"
  else
    font_ext="otf"
  fi
  find "${fonts_dl_dir}/${font}" -type f -name "*.${font_ext}" \! -name "*Windows Compatible*" -exec cp -f {} "$usr_font_dir" \;
}

setup_nerdfonts() {
  font_names=('CascadiaCode' 'Hack' 'Meslo')
  # first determine the latest stable tag
  nf_repo_owner="ryanoasis"
  nf_repo_name="nerd-fonts"
  get_stable_rel $nf_repo_owner $nf_repo_name
  nf_base_dl_url="https://github.com/${nf_repo_owner}/${nf_repo_name}/releases/download/${stable_rel}"
  for font in "${font_names[@]}"; do
    install_font "$font"
  done

  #TODO: update font-cache for linux
}

# installs git, unzip, brew, jq, nerdfonts
setup_prerequisites() {
  setup_git
  if [[ "$platform" == 'mac' ]]; then
    setup_brew
  fi
  setup_unzip
  setup_jq
  setup_nerdfonts
}

rm_bashcfg() {
  info "removing bash config"
  if [ -f $HOME/.bashrc ]; then
    rm $HOME/.bashrc
  fi
  if [ -f $HOME/.bash_history ]; then
    rm $HOME/.bash_history
  fi
  if [ -f $HOME/.bash_aliases ]; then
    rm $HOME/.bash_aliases
  fi
  success "bash config removed ${success_icon}"
}

source_zsh() {
  exec zsh
}

setup_zsh() {
  info "Checking zsh"
  if [[ $SHELL == *"zsh"* ]]; then
    success "zsh: passed! ${success_icon}"
  else
    setup_pkg "zsh"
    info "zsh: setting as default shell"
    chsh -s "$(command -v zsh)"
    success "zsh: set as default shell ${success_icon}"
    source_zsh
    success "zsh: config loaded ${success_icon}"
  fi
  rm_bashcfg # remove the bash config!
}

setup_asdf() {
  info "asdf: processing ..."
  check_command "asdf"
  is_asdf_available=$?
  if [[ $is_asdf_available == 0 ]]; then
    info "asdf: installing ..."
    asdf_repo_owner="asdf-vm"
    asdf_repo_name="asdf"
    asdf_clone_url="https://github.com/asdf-vm/asdf.git"
    get_stable_rel $asdf_repo_owner $asdf_repo_name
    git clone "${asdf_clone_url}" "$HOME/.asdf" --branch "${stable_rel}"
    info "asdf: installed! $success_icon"
  else
    success "asdf: already available as command! $success_icon"
  fi
}

setup_omz_plugins() {
  info "oh-my-zsh: scanning plugins..."
  # as MacOS stuck with 3.2 Bash, associative arrays are not available. We use a seperator "=><=" for creating keyvalue pair
  required_plugins=(
    "zsh - autosuggestions=><=https://github.com/zsh-users/zsh-autosuggestions"
  )

  local dir_zsh_plugins="$HOME/.oh-my-zsh/custom/plugins/"

  for plugin in "${required_plugins[@]}"; do
    local name="${plugin%%=><=*}"
    local repo="${plugin##*=><=}"
    if [ ! -d "$dir_zsh_plugins$name" ]; then
      info "oh-my-zsh: ${name} installing..."
      sleep 10
      git clone "${repo}" "$dir_zsh_plugins$name"
      success "oh-my-zsh: ${name} installed ${success_icon}"
    else
      success "oh-my-zsh: ${name} already available! ${success_icon}"
    fi
  done
  setup_asdf
}

setup_omz() {
  # setup omz & plugins
  info "oh-my-zsh: processing..." #oh-my-zsh
  if [ "$ZSH" != "$HOME/.oh-my-zsh" ]; then
    info "oh-my-zsh not found, installing"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "oh-my-zsh installed successfully! ${success_icon}"
  else
    success "oh-my-zsh already installed! ${success_icon}"
  fi
  setup_omz_plugins
}

setup_p10k() {
  local p10k_install_dir="$HOME/powerlevel10k"
  check_command "p10k" "${p10k_install_dir}/powerlevel10k.zsh-theme"
  local is_p10k_available=$?
  if [[ $is_p10k_available == 0 ]]; then
    info "p10k: installing ..."
    install_git_pkg "romkatv" "powerlevel10k" "$p10k_install_dir" "1" ""
    success "p10k: installed! $success_icon"
  else
    success "p10k: Command already available $success_icon"
  fi
  # source_zsh
}

setup_nvim() {
  setup_pkg "nvim"
}

setup_kitty() {
  # setup_pkg "kitty"
  # TODO: add logic for cask installation
  check_command "kitty"
  local is_kitty_avaialble=$?
  if [[ $is_kitty_avaialble == 0 ]]; then
    info "kitty: installing ..."
    brew install --cask kitty
    success "kitty: completed! $success_icon"
  else
    success "kitty: already available $success_icon"
  fi
}

# setup zsh, omz, p10k, nvim, kitty, eclipse?
setup_tooling() {
  setup_zsh
  setup_omz
  setup_p10k
  setup_nvim
  if [[ "$platform" == 'mac' ]]; then
    setup_kitty
  fi
  # TODO: setup_eclipse
}

link_file() {
  local src=$1 dst=$2
  local overwrite="" backup="" skip=""
  local action=""

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      declare currentSrc
      currentSrc="$(readlink $dst)"
      if [ "$currentSrc" == "$src" ]; then
        skip=true
      else
        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action
        case "$action" in
          o)
            overwrite=true
            ;;
          O)
            overwrite_all=true
            ;;
          b)
            backup=true
            ;;
          B)
            backup_all=true
            ;;
          s)
            skip=true
            ;;
          S)
            skip_all=true
            ;;
          *) ;;

        esac
      fi
    fi
    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}
    if [ "$overwrite" == "true" ]; then
      rm -rf "$dst"
      success "removed $dst"
    fi
    if [ "$backup" == "true" ]; then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi
    if [ "$skip" == "true" ]; then
      success "skipped $src"
    fi
  fi
  if [ "$skip" != "true" ]; then # "false" or empty
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles() {
  info "installing dotfiles"
  local overwrite_all=false backup_all=false skip_all=false
  for src in $(find -H "$dotfiles_dir" -maxdepth 2 -name '*.symlink' -not -path '*.git*'); do
    local dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

setup_configuration() {
  install_dotfiles
}


main() {
  setup_scriptenv     # setups platform specific & root directories
  setup_prerequisites # setup git, unzip, brew, jq, nerdfonts
  setup_tooling       # setup zsh, omz, p10k, nvim, kitty, eclipse?
  setup_configuration # setup config files linking (zsh, omz, p10k, gitconfig, nvim, kitty)
  rm_scriptdirs       # removes the tmp directories required by script during execution
  source_zsh
}

install_asdf_plugin() {
  local plugin_name=$1
  if [[ -z "$(asdf plugin list | grep ${plugin_name})" ]]; then
    info "asdf_plugin - ${plugin_name}: installing ..."
    asdf plugin add python
    success "asdf_plugin - ${plugin_name}: installed! $success_icon"
  else
    success "asdf_plugin - ${plugin_name}: Already installed $success_icon"
  fi
}

setup_python() {
  install_asdf_plugin "python"
}

setup_nodejs() {
  install_asdf_plugin "nodejs"
}

setup_go() {
  install_pkg "coreutils" # dependency for asdf-golang
  install_asdf_plugin "golang"
}

setup_programming() {
  setup_asdf # dependency for nodejs, python
  setup_python
  setup_nodejs
  setup_go
  # setup_jdk
}



lang() {
  setup_programming   # setup python, nodejs, go, java (sap-jdk)
  # echo "IN PROGRES, TRY LATER"
}

help() {
  echo ""
  echo "  Usage: ./setup.sh [options]"
  echo ""
  echo "  Setup script for MacOS/WSL2/Linux environment."
  echo "  This script tries to check if the pre-set commands are available, if not installs them and configures the dotfiles via. symlink"
  echo ""
  echo "  options:"
  echo "    help:    Prints this help info"
  echo "    main:    Runs the main script for setting up tooling, fonts, dotfiles"
  echo "    lang:    Runs the lang script for setting up programming languages (usually triggered after main)"
  echo ""
  echo "  In addition to above methods, you can go through the script & select individual functions to execute. e.g. ./setup.sh setup_p10k"
  echo "  Make sure you are aware of the pre/post installation steps of that particular method"

}

"$@" # options: main, lang, help

# # setup python, nodejs, go, java (sap-jdk) -- depends on asdf
# setup_programming() {
#   #TODO: setup in a way that cli script can be called with this mode
# }
