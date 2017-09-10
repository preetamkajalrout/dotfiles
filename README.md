# dotfiles
A naive attempt to create dotfiles for \*Nix based system for personal use.

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
- [ ] Add configuration for vim, kde-plasma (if possible)

## License
This project is licensed under [MIT License](./LICENSE)
