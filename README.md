# dotfiles
A personal set of dotfile configuration & script to automate the environment setup

## Pre-requisites
* XCode Command Line Tools
* [Homebrew](https://brew.sh/)
* Homebrew Cask
```bash
$ brew tap cask
```

## Installation
```
$ git clone git@github.com:preetamkajalrout/dotfiles.git
$ cd dotfiles
$ chmod +x start.sh
$ ./start.sh
```

## Components in the setup
- tmux
- neovim
- pyenv
  - Python 3
- dotfiles symlinks
- Oh-My-Zsh
  - zsh-autosuggestions
- vim-plug & neovim plugins
- NVM & latest LTS node
- Powerline
  - Powerline fonts
- Go (latest)
- [Rectangle](https://rectangleapp.com)

## TODO
- [ ] Change setup to be brew based for MacOS setup
- [ ] Add distinct component setup via. command line

## Thanks to...
[Zach Holman](https://github.com/holman/) and
[Mathias Bynens](https://github.com/mathiasbynens).
A lot of initial ideas were picked up from their dotfiles.

## License
This project is licensed under [MIT License](./LICENSE)
