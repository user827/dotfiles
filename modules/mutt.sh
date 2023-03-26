#!/bin/sh

install_module() {
  [ -d "$L_HOME"/Mail ] || mkdir -m 700 "$L_HOME"/Mail
  #[ -f "$L_HOME"/.mutt/norepo/mutt_provider ] || ln -s ../local "$L_HOME"/.mutt/norepo/mutt_provider
}
