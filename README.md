# dotfiles

Personal dotfile configuration & scripts to automate environment setup on macOS and Linux.

## Pre-requisites (macOS)
* XCode Command Line Tools: `xcode-select --install`
* [Homebrew](https://brew.sh/)

## Installation
```bash
git clone git@github.com:preetamkajalrout/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh main
```

## What Gets Installed

| Category | Tools |
|---|---|
| **Core Packages** | git, unzip, jq, llvm |
| **Fonts** | Nerd Fonts (Caskaydia Cove, Hack, MesloLG, Agave) |
| **Shell** | Pure Zsh, zsh-autosuggestions, Powerlevel10k |
| **Editor (Neovim)** | lazy.nvim, Native LSP (`vim.lsp.config`), blink.cmp, Auto-Dark-Mode, preetamkajalrout/cds.vim |
| **Terminal** | Kitty (macOS only) |
| **Toolchain (mise)** | Node.js, Python, gitui, delta, uv, ruff, cds-lsp, aube |
| **CLI Utilities** | ripgrep, fd, bat, fzf |
| **Keyboard** | Karabiner-Elements (via Goku) |

## macOS Packages
All macOS packages are managed via a `Brewfile`. To sync:
```bash
brew bundle --file=./Brewfile
```

## Linux Packages
All Linux packages are managed via an `Aptfile` and are automatically synced during `./setup.sh main`.

## Validation
```bash
chmod +x test.sh
./test.sh
```
