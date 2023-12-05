All my home configuration.

# Dependencies

In arch linux, ensure all dependencies are installed by
```
cd pacman/myhome
makepkg --syncdeps --install
cd ../myhomex
makepkg --syncdeps --install
```

# Installation

Setup `options` first. Then
```
git pull --verify-signatures
./install.sh
./init.sh
```

- For unattended installation, export `BATCH` with a value.

- for gnome terminal, set the terminal to start a login shell
- zsh is used as the default shell
