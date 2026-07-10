## Karabiner Configuration
Karabiner configuration now uses combination of 2 pieces
- [Goku](https://github.com/yqrashawn/GokuRakuJoudo) (EDN based syntax to make it less verbose)
- env variable `GOKU_EDN_CONFIG_FILE` (Updated in [zshrc](../zsh/zshrc.symlink))

## Installation
- Install goku with `brew install yqrashawn/goku/goku`
- Once available, just run `goku` from anywhere it will create the config that Karabiner can use

## Live Editing
- Use `gokuw` to live-edit the edn and changes reflecting back to config