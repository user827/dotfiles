#!/bin/sh

install_module() {
  for f in $L_GIT_ROOT/data/bat-extras/src/*; do
    out=${f##*/}
    Lln "$f" "$L_USER_BINARIES/${out%.sh}"
  done
}
