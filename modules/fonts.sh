#!/bin/sh

install_module() {
  fc_list=$(fc-list)
  case "$fc_list" in
    *'SauceCodePro Nerd Font Mono'*)
      ;;
    *)
      if command -v pacman > /dev/null; then
        sudo pacman -S ttf-sourcecodepro-nerd
      else
        log warn 'Terminal font SauceCodePro Nerd Font Mono is missing'
      fi
      ;;
  esac
  case "$fc_list" in
    *'Noto Color Emoji'*)
      ;;
    *)
      if command -v pacman > /dev/null; then
        sudo pacman -S noto-fonts-emoji
      else
        log warn 'Terminal font Noto Font Emoji is missing'
      fi
      ;;
  esac
}
