#!/bin/bash
set -eu

#. /usr/lib/byobu/include/shutil
#TODO above does not work so as a workaround
color() {
  if [ "$1" = b ]; then
    printf %s '#[default]#[fg=black,bold,bg=red]'
  else
    printf %s '#[default] '
  fi
}

_systemctl() {
  local failed_sys failed_user failed
  failed_sys=$(systemctl show -p NFailedUnits | cut -d= -f2)
  failed_user=$(systemctl --user show -p NFailedUnits | cut -d= -f2)
  failed=$(( failed_sys + failed_user ))
  if [ $failed -gt 0 ]; then
    color b r k; printf "%s" "$failed"; color --
  fi
}

_systemctl
# vi: syntax=sh sts=2 expandtab
