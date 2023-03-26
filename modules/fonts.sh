#!/bin/sh

install_module() {
  fc_list=$(fc-list)
  case "$fc_list" in
    *'SauceCodePro Nerd Font Mono'*)
      ;;
    *)
      log warn 'Terminal font SauceCodePro Nerd Font Mono is missing'
      ;;
  esac
  case "$fc_list" in
    *'Noto Color Emoji'*)
      ;;
    *)
      log warn 'emoji colorfont missing'
      ;;
  esac
}
