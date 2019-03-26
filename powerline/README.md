# Installation

Following components needed for powerline to be used properly in bash, tmux & vim. Assumption is usage of python2.7

* powerline
* powerline-fonts
* powerline-gitstatus

## powerline
Homepage [https://github.com/powerline/powerline]

### install
```
sudo pip install powerline-status
```

## powerline-fonts
Homepage [https://github.com/powerline/fonts]

### install
```
git clone https://github.com/powerline/fonts.git
cd fonts/
```
Linux/OSX
```
./install.sh
```

Windows (To be installed using Powershell not WSL)
```
./install.ps1
```
Now select the font in terminal settings.

## powerline-gitstatus
Homepage [https://github.com/jaspernbrouwer/powerline-gitstatus]

### install

```
sudo pip install powerline-gitstatus
```

### configuration
Copy configuration from [./config/](./config/) to respective folder in installation config folder
```
/usr/local/lib/python2.7/dist-packages/powerline/config_files/
```

For colorschemes copy only the git relevant configuration.
