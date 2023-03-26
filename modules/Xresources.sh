#!/bin/sh

install_module() {
  # Ubuntu does not use cpp
  xresgen=$modbase/Xresources/Xresources
  xres=$L_GEN_DIR/home/Xresources
  cpp -P "$xresgen" > "$xres"
  if [ -n "${DISPLAY:-}" ]; then
    xrdb -merge -nocpp "$xres"
  else
    echo "skipping xrdb -merge"
  fi
}
