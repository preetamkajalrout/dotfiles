# dotfiles
A personal set of dotfile configuration & script to automate the environment setup

## MUST READ
This project assumes user is on **Debian based system, specifically Ubuntu** (It can be WSL).

## Installation
```
$ git clone git@github.com:preetamkajalrout/dotfiles.git
$ cd dotfiles
$ chmod +x start.sh
$ ./start.sh
```

## Components in the setup
- Git (There only when this repo is downloaded as zip. Ideally, Git should be available since you are cloning this repo)
- Zsh (Setups & makes it default shell)
- Tmux
- vim
- dotfiles linking
- Oh-My-Zsh
  - zsh-autosuggestions
- Vundle & Plugins
- NVM & latest LTS node
- Vim Plugins
  - YouCompleteMe
  - Powerline

## TODO
- [ ] Make each setup manual instead of package manager dependent
- [ ] Add powerline configuration step for setup task
- [ ] Add distinct component setup via. command line

## Thanks to...
[Zach Holman](https://github.com/holman/) and
[Mathias Bynens](https://github.com/mathiasbynens) .
I copied shamelessly a lot of scripts and ideas from their dotfiles :grin:

## License
This project is licensed under [MIT License](./LICENSE)
