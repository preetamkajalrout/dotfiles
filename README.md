# dotfiles
A naive attempt to create dotfiles for \*Nix based system for personal use.

## MUST Install Following for dev environment to work seemlessly
* python2.7
* nodejs
* grip (for markdown preview)
* git
* vundle package manager [https://github.com/VundleVim/Vundle.vim]
* js-beautify

## Installation
```
$ git clone git@github.com:preetamkajalrout/dotfiles.git
$ cd dotfiles
$ chmod +x start.sh
$ ./start.sh
```

## Usage
Add following to `~/.bashrc` file:
```
# Add custom bash_profile
if [ -f ~/.bash_profile ]; then
    . ~/.bash_profile
fi
```

Execute following on the `terminal`
```
$ source ~/.bashrc
```

## TODO
- [x] Initial setup for bash prompt and bash profile
- [ ] Add installation script for development environment setup
- [x] Add configuration for vim
- [x] Add overwrite option for changes done to initial files symlinks

## Thanks to...
[Zach Holman](https://github.com/holman/) and
[Mathias Bynens](https://github.com/mathiasbynens) .
I copied shamelessly a lot of scripts and ideas from their dotfiles :grin:

## License
This project is licensed under [MIT License](./LICENSE)
