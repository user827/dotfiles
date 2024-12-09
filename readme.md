All my home configurations.

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
gpg --receive-keys 0x8DFE60B7327D52D6
```

Then trust and sign the key or just trust it ultimately. Afterwards:

```
git pull --verify-signatures
./install.sh
./init.sh
```

- For unattended installation, export `BATCH` with a value.

- zsh is used as the default shell. Use `chsh -s $(which zsh)` to change it.

# Update

Run `updatedots`.

# Manual setup

- Set nerd console fonts

- Enable tray icons:
```
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
```
