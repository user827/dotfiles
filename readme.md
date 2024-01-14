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
gpg --search-keys user827
git pull --verify-signatures
./install.sh
./init.sh
```

- For unattended installation, export `BATCH` with a value.

- zsh is used as the default shell

# Update

Run `updatedots`.
