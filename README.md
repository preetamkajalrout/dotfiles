# dotfiles
A personal set of dotfile configuration & script to automate the environment setup

## Pre-requisites
* XCode Command Line Tools [ `xcode-select --install` ]
* [Homebrew](https://brew.sh/)
* Homebrew Cask
```bash
$ brew tap cask
```

## Installation
```
$ git clone git@github.com:preetamkajalrout/dotfiles.git
$ cd dotfiles
$ chmod +x setup.sh
$ ./setup.sh main
```

## Components in the setup
- git, brew, unzip, jq
- nerd-fonts (CascadiaCode, Hack, Meslo)
- neovim
- zsh, oh-my-zsh (with plugins -- listed below), asdf
- oh-my-zsh plugins
  - zsh-autosuggestions
- asdf
  - python
  - nodejs
  - golang
- dotfiles symlinks

## TODO
- [X] Change setup to be brew based for MacOS setup
- [ ] Add distinct component setup via. command line
- [ ] neovim package bug
- [ ] merge dotfiles with their respective tool setup / add tool specific location e.g. kitty should store in '~/.config/kitty/kitty.conf' not on '~/.kitty.conf'
- [ ] Add rectangleapp, karabiner config for macos based system

## License
This project is licensed under [MIT License](./LICENSE)
