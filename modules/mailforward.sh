#!/bin/sh

install_module() {
  local "confpath=$modbase/mailforward" uid admin
  if [ "${skip_mailforward:-}" = 1 ]; then
    warn skipping
    return 0
  fi

  local admin="$mail_admin_user"

  if [ "$USER" = "$admin" ]; then
    prepare_gen "$confpath/forward.admin" "$L_HOME/.forward" 644 \
      -e "s,@home@,$HOME,g" \
      -e "s,@mail_listeners@,$mail_listeners,g"
  else
    prepare_gen "$confpath/forward" "$L_HOME/.forward" 644 \
      -e "s,@home@,$HOME,g" \
      -e "s,@admin@,$admin,g"
  fi
}
