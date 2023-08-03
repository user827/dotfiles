#!/bin/sh

install_module() {
  local "confpath=$modbase/maildrop" uid admin hostname
  if [ -f ~/.forward ] && [ -f "$L_GEN_DIR/home/mailfilter" ]; then
    msg maildrop set
    return 0
  fi
  if [ -f ~/.skipmaildrop ]; then
    warn skipping maildrop
    return 0
  fi

  printf "%s" "Skip setting maildrop? [y/N] "
  read -r ans
  if [ "$ans" = y ]; then
    warn skipping
    touch ~/.skipmaildrop
    return 0
  fi

  printf "%s" "Enter admin user "
  read -r admin

  hostname=$(hostname)
  prepare_gen "$confpath/mailfilter" "$L_GEN_DIR/home/mailfilter" 600 \
    -e "s,@user_binaries@,$L_USER_BINARIES,g" \
    -e "s,|admin|,$admin,g" \
    -e "s,|hostname|,$hostname,g" \

  uid=$(id -u)
  [ -d "$L_GEN_DIR/bin" ] || mkdir "$L_GEN_DIR/bin"
  prepare_gen "$confpath/mailfilterdbus" "$L_GEN_DIR/bin/mailfilterdbus" 700 -e \
    "s,@uid@,$uid,g"

  install_file "$confpath"/forward "$L_HOME/.forward"
  if ! [ -f "$HOME"/.mailfilter.local ]; then
    : > "$HOME"/.mailfilter.local
    chmod 600 "$L_HOME/.mailfilter.local"
  fi
}
