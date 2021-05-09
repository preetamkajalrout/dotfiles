#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)

set -e

# Utility methods
info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

success_icon="✅ "
error_icon="⛔️ "
cfg_shell="$HOME/.zshrc"

# Packages from ubuntu repository or github repo
pkg_git="git"
pkg_zsh="zsh"
pkg_tmux="tmux"
pkg_python3="python3-dev"
pkg_pip3="python3-pip"
pkg_nvm="https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh"
pkg_vundle="https://github.com/VundleVim/Vundle.vim.git"
pkg_ohmyzsh="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
pkg_powerline="powerline-status"
pkg_powerlinefonts="https://github.com/powerline/fonts.git"

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_pkg () {
  info "$pkg_$1: installing..."
  sudo apt install -y "$pkg_$1"
  success "$1: installed!"
}

rm_bashcfg () {
  if [ -f $HOME/.bashrc ]
  then
    rm $HOME/.bashrc
  fi
  if [ -f $HOME/.bash_history ]
  then
    rm $HOME/.bash_history
  fi
  if [ -f $HOME/.bash_aliases ]
  then
    rm $HOME/.bash_aliases
  fi
}

source_shell_cfg () {
  if [ -f "$cfg_shell" ]
  then
    source $cfg_shell
  fi
}

install_ohmyzsh () {
  info "oh-my-zsh: processing..." #oh-my-zsh
  if [ "$ZSH" != "$HOME/.oh-my-zsh" ]
  then
    info "oh-my-zsh not found, installing"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "oh-my-zsh installed successfully! ${success_icon}"
  else
    success "oh-my-zsh already installed! ${success_icon}"
  fi
  install_ohmyzshplugins
}

install_ohmyzshplugins () {
  info "oh-my-zsh: scanning plugins..."
  declare -A required_plugins
  required_plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  )

  local dir_zsh_plugins="$HOME/.oh-my-zsh/custom/plugins/"

  for name in ${!required_plugins[@]}
  do
    if [ ! -d "$dir_zsh_plugins$name" ]
    then
      info "oh-my-zsh: ${name} installing..."
      git clone "${required_plugins[$name]}" "$dir_zsh_plugins$name"
      success "oh-my-zsh: ${name} installed ${success_icon}"
    else
      success "oh-my-zsh: ${name} already available! ${success_icon}"
    fi
  done

}

install_vundle () {
  info "vundle: procesing..." #package manager for vim check
  local vundle_dir="$HOME/.vim/bundle/Vundle.vim"
  if [ ! -d "$vundle_dir" ] #vundle not found
  then
    info "vundle not found, installing"
    git clone $pkg_vundle $vundle_dir
    success "vundle installed! ${success_icon}"
    info "installing vim plugins"
    vim +PluginInstall +qall
    success "vim plugins installed! ${success_icon}"
  else
    success "vundle: complete! ${success_icon}"
  fi
}

install_nvm () {
  info "nvm: processing..." #node version manager

  local dir_nvm_versions="$HOME/.nvm/versions/node"

  # checking if nvm versions exists && has any node versions installed
  if [ -d "$dir_nvm_versions" ] && [ ! -z "$(ls -A $dir_nvm_versions)" ] # '-z' => string is null, that is, has zero length
  then
    # nvm found
    success "nvm already installed! ${success_icon}"
  else
    info "nvm not found, installing"
    curl -o- $pkg_nvm | bash
    success "nvm installed successfully! ${success_icon}"
    info "loading nvm to current terminal shell.."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    info "installing latest lts of node via. nvm"
    nvm install node
    success "node installed successfully! ${success_icon}"
  fi
}

install_ycm () {
  info "vim-youcompleteme: processing..."
  if [ -z "$(dpkg -l | grep vim-youcompleteme)" ]
  then
    info "vim-youcompleteme: installing..."
    sudo apt install -y vim-youcompleteme
  else
    success "vim-youcompletem: already available! ${success_icon}"
  fi
  vim-addon-manager install youcompleteme
  success "vim-youcompleteme: completed! ${success_icon}"
}

install_powerlinefonts () {
  info "powerline: installing/updating pre-patched fonts..."
  git clone $pkg_powerlinefonts --depth=1 $HOME/powerline-fonts/
  $HOME/powerline-fonts/install.sh
  rm -rf $HOME/powerline-fonts/
  success "powerline: pre-patched fonts installed! ${succes_icon}"
  
  user "powerline: Cascadia Code fonts are not installed! It can be installed from 'https://github.com/microsoft/cascadia-code/releases'"
}

install_powerline () {
  info "powerline: processing..."
  if [ -z "$(pip3 show powerline-status)" ] # '-z' => string is null, that is, has zero length
  then
    info "powerline: installing main package..."
    pip3 install $pkg_powerline
  else
    success "powerline: main package is already installed! ${success_icon}"
  fi

  install_powerlinefonts
  
  success "powerline: completed! ${success_icon}"

}

install_vimplugins () {
  install_ycm
  install_powerline
}

install_go () {
  info "go: processing..."
  dir_go="$HOME/go"
  dir_godl="$HOME/go-dl"
  latest_gover=$(curl -s https://golang.org/VERSION?m=text) # get latest version from golang server
  pkg_go="$latest_gover.linux-amd64.tar.gz"
  pkg_go_src="https://golang.org/dl/$pkg_go"
  is_install="false"
  go_exists="false"

  # check if go is already installed
  if [ -d "$dir_go" ] # go is installed
  then
    if [ "$(go version | grep -oP 'go[0-9.]+')" != "$latest_gover" ] # check if latest go is installed
    then
      is_install="true"
      go_exists="true"
    fi
  else # go is not installed
    is_install="true"
  fi
  
  # install if needed
  if [ $is_install == "true" ]
  then
    # download package
    info "go: downloading..."
    mkdir -p $dir_godl
    wget --no-check-certificate --continue --show-progress "$pkg_go_src" -P "$dir_godl"
    if [ $go_exists == "true" ] # remove old go if updating
    then
      info "go: updating..."
      rm -rf dir_go
    else
      info "go: installing..."
    fi
    tar -C $HOME -xzf "$dir_godl/$pkg_go"
    rm -rf $dir_godl
    success "go: completed! ${success_icon}"
  else
    success "go: already latest! ${success_icon}"
  fi
  
}

check_git () {
  info "checking git"
  if ! command -v git &> /dev/null # git check
  then
    install_pkg "git"
  else
    success "git: passed! ${success_icon}"
  fi
}

check_zsh () {
  info "checking zsh"
  if [ "$SHELL" != "/usr/bin/zsh" ] # not zsh
  then
    install_pkg "zsh"
    info "zsh: setting as default shell..."
    chsh -s $(which zsh)
    success "zsh is now default shell"
    rm_bashcfg
    source_shell_cfg
  else
    rm_bashcfg
    success "zsh: passed! ${success_icon}"
  fi
}

check_tmux () {
  info "checking tmux"
  if ! command -v tmux &> /dev/null # tmux check
  then
    install_pkg "tmux"
  else
    success "tmux: passed! ${success_icon}"
  fi
}

check_vim () {
  info "checking vim"
  if ! command -v vim &> /dev/null # vim check
  then
    install_pkg "vim"
    exit
  else
    success "vim: passed! ${success_icon}"
  fi
}

check_python_all () {
  info "checking python3"
  if ! command -v python3 &> /dev/null #python3 check
  then
    install_pkg "python3"
  else
    success "python3: passed! ${success_icon}"
  fi

  info "checking pip3"
  if ! command -v pip3 &> /dev/null #pip3 check
  then
    install_pkg "pip3"
  else
    success "pip3: passed! ${success_icon}"
  fi
}

# Check Prerequisites before starting copy
check_prerequisites () {
  info "checking prequisites & installing modules.."
  check_git
  check_zsh
  check_tmux
  check_vim
  check_python_all
}

install_dotfiles () {
  info "installing dotfiles"

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

# Install modules/components dependent on core environment
setup_env () {
  install_ohmyzsh
  install_vundle
  install_nvm
  install_vimplugins
  install_go
}

# Creates symlink for all the dotfiles in home directory
check_prerequisites
install_dotfiles
setup_env
