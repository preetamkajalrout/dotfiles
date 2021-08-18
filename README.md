# dotfiles
A personal set of dotfile configuration & script to automate the environment setup

## MUST READ
This project assumes user is on **Debian based system, specifically Ubuntu** (It can be WSL).

## Pre-requisites
Until the feature is added, pyenv installation needs to be done by running:

```bash
$ curl https://pyenv.run | bash
```

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
- Python 3
- dotfiles linking
- Oh-My-Zsh
  - zsh-autosuggestions
- Vundle & Plugins
- NVM & latest LTS node
- Vim Plugins
  - YouCompleteMe
  - Powerline
- Go (latest)

## Extra tool-specific setup
### Git
If environment is WSL2, Enable usage of Git Credential manager from Windows Host. Replace `<Username>` as per context

```bash
[credential]
	helper = /mnt/c/Users/<Username>/AppData/Local/Programs/Git/mingw64/libexec/git-core/git-credential-manager.exe
```

## TODO
- [ ] Make each setup manual instead of package manager dependent
- [ ] Add powerline configuration step for setup task
- [ ] Add distinct component setup via. command line
- [ ] Add `pyenv` installer to the script

## Thanks to...
[Zach Holman](https://github.com/holman/) and
[Mathias Bynens](https://github.com/mathiasbynens) .
I copied shamelessly a lot of scripts and ideas from their dotfiles :grin:

## License
This project is licensed under [MIT License](./LICENSE)
